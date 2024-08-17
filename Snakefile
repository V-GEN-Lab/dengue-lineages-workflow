if not config:

    configfile: "config/config.yaml"


build_names = ["denv1", "denv2", "denv3", "denv4"]
dataset_files = [
    "pathogen.json",
    "sequences.fasta",
    "genome_annotation.gff3",
    "README.md",
    "CHANGELOG.md",
]

# Helper functions to allow build-specific annotations
def annotation_path(wildcards):
    if "annotation" in config[wildcards.build_name]:
        return config[wildcards.build_name]["annotation"]
    return "resources/genome_annotation.gff3"

rule all:
    input:
        datasets=expand(
            "datasets/{dataset}/{file}", dataset=build_names, file=dataset_files
        ),

rule augur_ancestral:
    # "Reconstructing ancestral sequences and mutations"
    input:
        tree="resources/{build_name}/tree.nwk",
        alignment="resources/{build_name}/aligned.fasta",
        reference="resources/{build_name}/reference.fasta",
    output:
        node_data="results/{build_name}/nt_muts.json",
    params:
        inference="joint",
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --root-sequence {input.reference} \
            --output-node-data {output.node_data} \
            --inference joint
        """

rule augur_translate:
    # "Reconstructing ancestral sequences and mutations"
    input:
        tree="resources/{build_name}/tree.nwk",
        reference="resources/{build_name}/reference.gb",
        ancestral_muts="results/{build_name}/nt_muts.json",
    output:
        node_data="results/{build_name}/aa_muts.json",
    shell:
        """
        augur translate \
            --tree {input.tree} \
            --reference-sequence {input.reference} \
            --output-node-data {output.node_data} \
            --ancestral-sequences {input.ancestral_muts} \
        """

rule augur_clades:
    # "Adding internal clade labels"
    input:
        tree="resources/{build_name}/tree.nwk",
        nuc_muts="results/{build_name}/nt_muts.json",
        aa_muts="results/{build_name}/aa_muts.json",
        clades="resources/{build_name}/clades.tsv",
    output:
        node_data="results/{build_name}/clades.json",
    shell:
        """
        augur clades \
            --tree {input.tree} \
            --mutations {input.nuc_muts} {input.aa_muts} \
            --clades {input.clades} \
            --membership-name clade_membership \
            --label-name lineage \
            --output-node-data {output.node_data} 2>&1 | tee {log}
        """
rule colors:
    input:
        ordering="resources/color_ordering.tsv",
        color_schemes="resources/color_schemes.tsv",
        metadata="resources/metadata.tsv",
    output:
        colors="results/{build_name}/colors.tsv",
    shell:
        """
        python3 scripts/assign-colors.py \
            --ordering {input.ordering} \
            --color-schemes {input.color_schemes} \
            --output {output.colors} \
            --metadata {input.metadata} 2>&1
        """

rule augur_export:
    # "Exporting data files for for auspice"
    input:
        colors="results/{build_name}/colors.tsv",
        tree="resources/{build_name}/tree.nwk",
        metadata="resources/metadata.tsv",
        clades="results/{build_name}/clades.json",
        nt_muts="results/{build_name}/nt_muts.json",
        aa_muts="results/{build_name}/aa_muts.json",
        auspice_config="resources/{build_name}/auspice_config.json",
    output:
        auspice_json="auspice/tree_{build_name}.json",
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.nt_muts} {input.clades} \
            --colors {input.colors} \
            --auspice-config {input.auspice_config} \
            --include-root-sequence \
            --output {output.auspice_json}
        """

rule assemble_dataset:
    input:
        reference="resources/{build_name}/reference.fasta",
        tree="auspice/tree_{build_name}.json",
        pathogen_json="resources/{build_name}/pathogen.json",
        sequences="resources/{build_name}/sequences.fasta",
        annotation="resources/{build_name}/genome_annotation.gff3",
        readme="resources/{build_name}/README.md",
        changelog="resources/{build_name}/CHANGELOG.md",
    output:
        reference="datasets/{build_name}/reference.fasta",
        tree="datasets/{build_name}/tree.json",
        pathogen_json="datasets/{build_name}/pathogen.json",
        sequences="datasets/{build_name}/sequences.fasta",
        annotation="datasets/{build_name}/genome_annotation.gff3",
        readme="datasets/{build_name}/README.md",
        changelog="datasets/{build_name}/CHANGELOG.md",
    shell:
        """
        cp {input.reference} {output.reference}
        cp {input.tree} {output.tree}
        cp {input.pathogen_json} {output.pathogen_json}
        cp {input.sequences} {output.sequences}
        cp {input.annotation} {output.annotation}
        cp {input.readme} {output.readme}
        cp {input.changelog} {output.changelog}
        """

rule clean:
    # Removing directories: {params}"
    params:
        "results",
        "auspice",
    shell:
        "rm -rf {params}"
