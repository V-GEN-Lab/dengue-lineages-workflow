# Dengue Lineages Dataset Workflow

This repository contains the source code and datasets used to implement the Dengue lineages system in NextClade. The workflow is based on the organizational structure initially developed for the Mpox virus, available [here](https://github.com/nextstrain/mpox/tree/master/nextclade).

## Overview

This repository contains the workflow for generating datasets from the representative trees produced in the Dengue Virus Lineage Systems project, as described by [Hill et al., 2024](https://doi.org/10.1101/2024.05.16.24307504). These datasets are designed for integration into the NextClade tool, facilitating the implementation and analysis of dengue virus lineages.

## Repository Contents

- **datasets/**: Contains the curated dengue virus sequence datasets.
- **scripts/**: Includes the scripts used for data processing and analysis.
- **config/**: Maps various dengue virus variants to the correct genomic annotation file
- **resources/**: Files necessary for constructing and configuring the datasets

## How to Use

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/V-GEN-Lab/dengue-lineages-workflow.git
   ```
2. **Setup Environment**:
   Follow the instructions in the `docs/setup.md` to install dependencies and configure your environment.

3. **Run the Workflow**:
   Execute the main workflow using Snakemake:
   ```bash
   snakemake --cores <number_of_cores>
   ```

## Maintainers and Contacts

- [James Siqueira Pereira](https://github.com/jamessiqueirap)¹ ²
- [Alex Ranieri](https://github.com/alex-ranieri)¹

## Affiliations

¹ Center for Viral Surveillance and Serological Assessment [(CeVIVAS)](https://bv.fapesp.br/en/auxilios/110575/continuous-improvement-of-vaccines-center-for-viral-surveillance-and-serological-assessment-cevivas/) at the [Butantan Institute](https://en.butantan.gov.br/).

² University of São Paulo [(USP)](https://www5.usp.br/english/institutional/).


## Acknowledgements

Special thanks to the Nextstrain team for their continuous support and for providing the base workflow for Mpox, which served as an inspiration for this project.
