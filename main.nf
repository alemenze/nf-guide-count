#!/usr/bin/env nextflow
/*
                              (╯°□°)╯︵ ┻━┻

========================================================================================
                Workflow for stitching reads, and quantifying guide RNAs
                For use with specific projects
========================================================================================
                  https://github.com/alemenze/nf-guide-count
*/

nextflow.enable.dsl = 2

def helpMessage(){
    log.info"""

    Usage:
        nextflow run alemenze/nf-guide-count \
        --samplesheet ./metadata.csv \
        --guides ./guides.csv \
        -profile singularity

    Required parameters:
        --samplesheet               CSV file with sample information
        --guides                    CSV file with the guide RNA information
        -profile                    Currently available for docker (local) or singularity (HPC)

    """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

if (params.samplesheet) {file(params.samplesheet, checkIfExists: true)} else { exit 1, 'Samplesheet file not specified!'}
if (params.guides) {file(params.guides, checkIfExists: true)} else { exit 1, 'Guides file not specified!'}

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map{ row -> tuple(row.sample_id), file(row.read1), file(row.read2) }
    .set{ fastqs }

Channel
    .fromPath(params.guides)
    .splitCsv(header: true)
    .map { row -> [ row.name, row.guide ] }
    .set { guides }

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////
include { Processing } from './modules/main_workflows/processing'
////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

// Full workflow
workflow {
    Processing(
        fastqs,
        guides
    )
}