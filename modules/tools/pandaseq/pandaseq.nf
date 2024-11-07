// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process Panda_Stitch {
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/stitched",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/pandaseq"

    input:
        tuple val(meta), path(reads)
    
    output:
        tuple val(meta), path("*_stitched.fastq"), emit: paired
        tuple val(meta), path("log.txt"), emit: pandalog

    script:
        """
        pandaseq -f ${reads[0]} -r ${reads[1]} -w ${meta}_stitched.fastq -g log.txt
    
        """

}
