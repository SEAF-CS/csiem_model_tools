# Groundwater Boundary Condition Workflow

This directory stores the MATLAB scripts that transform raw groundwater monitoring datasets into `bc_files_extended` boundary condition files for model ingestion. The process runs entirely inside MATLAB and consists of four sequential scripts that progressively clean, aggregate, and expand the data.

## Directory Layout

- `raw_datasets`: Source workbooks supplied by monitoring programs. The scripts expect:
  - `Updated_CSIRO_results04042025/westport__gw_and_totalN_totim*.xlsx`
  - `N_speciation_for_ModelZones_Final.xlsx`
  - `WWMSP3.3_Porewater/Copy of WWMSP3.3_CombinedSampleDetails_BeachOffshorePorewater_PRELIMINARY_072024.xlsx`
- `comp_datasets`: Intermediate CSVs created by the workflow (`GW_processdata.csv`, `BC_GW_masterfile.csv`, `samples_guide.csv`). The `samples_guide.csv` file is a curated lookup produced using QGIS from the field sampling log and maps each porewater `SiteID` to its corresponding `MH_zone` identifier—the groundwater zone ID carried through the workflow until the final rename to `GW_zone`.
- `bc_files`: Zone-specific boundary condition files built from the master file.
- `bc_files_extended`: Final boundary condition files that cover the full 1980-2024 monthly window.

## End-to-End Workflow

```
raw_datasets --> GW_processdata.m --> GW_BC_masterfile.m --> GW_BC_creation.m --> GW_BC_file_loop.m
                   |                    |                    |                    |
                   +--> comp_datasets/  +--> comp_datasets/  +--> bc_files/       +--> bc_files_extended/
                        GW_processdata.csv   BC_GW_masterfile.csv   SGD_<zone>_...     SGD_zone<zone>_...
```

Run the scripts in the order shown below. Each script assumes that the output from the previous step already exists.

1. **`GW_processdata.m`**  
   - Reads the CSIRO groundwater result files and converts them into time series per model zone.  
   - Uses a lookup table to map file identifiers to calendar months (Jan 2021 to Dec 2022). If new source files are provided, update `date_lookup`.  
   - Adds nitrogen speciation (`pDON`, `pNH3`, `pNOx`) from `N_speciation_for_ModelZones_Final.xlsx`, converts monthly totals to DON/NH4/NOx loads, and joins Mooring Hub (MH) zones.  
   - Outputs `comp_datasets/GW_processdata.csv`.

2. **`GW_BC_masterfile.m`**  
   - Pulls the processed fluxes (`GW_processdata.csv`), porewater chemistry (In-situ, MAFRL, CCWA tabs), and `samples_guide.csv`.  
   - Aggregates by `MH_zone` and `Date`, sums fluxes, and applies zone-specific mean chemistries (salinity, DOC, dissolved oxygen, etc.). Zones without direct measurements inherit chemistry constants from nearby or analogous zones as defined in `zone_map`.  
   - Computes flow-weighted concentrations (DON, NH4, NOx) and the associated speciation fractions (`pNH3`, `pNOx`, `pDON`), converting concentrations to mmol m^-3.  
   - Writes the consolidated boundary condition table to `comp_datasets/BC_GW_masterfile.csv`.

3. **`GW_BC_creation.m`**  
   - Reads the master file, splits it by `MH_zone`, formats dates as `dd/mm/yyyy`, and exports one CSV per zone under `bc_files`.  
   - Relabels the workflow's `MH_zone` identifier to a more descriptive `GW_zone` field in the exported tables, while retaining the original `MH_zone` column for traceability.  
   - Filenames follow `SGD_<zone>_<start>_<end>.csv`, where `start` and `end` reflect the available date range in the source data.

4. **`GW_BC_file_loop.m`**  
   - Loads every file in `bc_files`, converts timestamps to MATLAB datetimes, and enforces start-of-month alignment.  
   - Extracts a 24-month reference window (Jan 2021 to Dec 2022). 
   - Repeats the 2021-2022 reference block to fill the target period `1980-01-01` to `2024-04-01`, then reinserts the measured records (including the 2021-2022 observations) wherever they exist so the replicated rows only fill gaps.  
   - Saves the extended files under `bc_files_extended` as `SGD_zone<zone>_19800101_20240401.csv` with timestamps formatted `dd/MM/yyyy HH:mm:ss`.

## Usage Notes

- Always verify that new raw workbooks match the expected sheet layouts before running the scripts; column name drift will cause failures.  
- If you extend the modelling window, adjust `startDate`, `endDate`, and the reference years in `GW_BC_file_loop.m`.  
- Keep directory names identical to the paths hard-coded in the scripts or update the script variables accordingly.  
- The scripts clear the MATLAB workspace; run them individually to avoid losing variables that you may want to inspect between steps.

## Outputs

- `comp_datasets/GW_processdata.csv`: Monthly fluxes and nitrogen loads per zone.  
- `comp_datasets/BC_GW_masterfile.csv`: Aggregated boundary condition dataset used to seed individual zone files.  
- `bc_files/SGD_*.csv`: Zone-specific boundary condition time series over the measured period.  
- `bc_files_extended/SGD_zone*_19800101_20240401.csv`: Final monthly boundary condition records spanning the full historical horizon for model import.
