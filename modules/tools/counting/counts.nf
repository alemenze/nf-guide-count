// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process CountGuides {
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/counts",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    input:
        tuple val(meta), path(stitched_reads)
        path(guides)

    output:
        tuple val(meta), path("*_guide_counts.csv"), emit: counts

    script:
        """
        echo "Name,Guide,Count" > ${meta}_guide_counts.csv
        while IFS=, read -r name guide; do
            # Skip the header line if it's the first line
            if [[ "$name" == "name" && "$guide" == "guide" ]]; then
                continue
            fi
            count=\$(grep -c "\$guide" ${stitched_reads})
            echo "\$name,\$guide,\$count" >> ${meta}_guide_counts.csv
        done < ${guides}
        """
}