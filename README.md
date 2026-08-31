
CC BY 4.0
# Supplementary Information

Supplementary data which uses equal-representation donor selection across sex and Alzheimer's disease (AD) status to study prefrontal cortex (PFC) tissue.

## Human Donor Selection (`selection information/`)

Donors were drawn from Seattle Alzheimer's Disease Brain Cell Atlas (SEA-AD). Images are of broadman area 9 of the DLPFC. While raw human images are not included in this repo, all human tissue images are freely available at https://brain-map.org/consortia/sea-ad


Selection Criteria:

| Group | Criteria |
|---|---|
| AD - Male | Braak ≥ V, High AD neuropathological change, Dementia, Male |
| AD - Female | Braak ≥ V, High AD neuropathological change, Dementia, Female |
| Control - Male | Braak IV, No dementia, Not AD / Low / Intermediate neuropathology, Male |
| Control - Female | Braak IV, No dementia, Not AD / Low / Intermediate neuropathology, Female |

Four donors per group (16 total) were randomly selected using a composite tissue-quality weighting (PMI, brain pH, RIN). Severely affected donors were excluded from the AD pool prior to selection.

`find_donors.py` reproduces the selection from `DONOR-METADATA.csv` with a fixed random seed (`np.random.seed(42)`).

## Rat PFC Image Stacks (`rat_pfc_raw_stack/`)

TIFF files from rat prefrontal cortex tissue sections. Three rats per sex, and two sections per rat.

**Channels:**
- **NeuN488**: NeuN antibody (488 nm); marks neuronal nuclei
- **GFAP594**: GFAP antibody (594 nm); marks astrocytes
- **DAPI350**: DAPI antibody; marks nuclei

Each `.tif` file contains a DAPI channel and another channel; either NeuN or GFAP. 

## IMPORTANT NOTE

The TIFF files are stored in github's **Large File Storage (LFS)**. To pull them from LFS, run **git lfs pull**. For more information, see: https://graphite.com/guides/how-to-use-git-lfs-pull
