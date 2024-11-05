// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process CountGuides {
    tag "${meta}"
    label 'process_medium'

    container "alpine:3.12"

    publishDir "${params.outdir}/counts",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    input:
        tuple val(meta), path(stitched_reads)
        val guides

    output:
        tuple val(meta), path("*_guide_counts.csv"), emit: counts

    script:
        """
        echo "Label,Guide,Count" > ${params.outputDir}/${meta}_guide_counts.csv
        while IFS=, read -r label guide; do
            count=\$(grep -c "\$guide" ${stitched_reads})
            echo "\$label,\$guide,\$count" >> ${params.outputDir}/${meta}_guide_counts.csv
        done <<< "\$(printf "%s\n" ${guides.collect().join('\n')})"
        """
}