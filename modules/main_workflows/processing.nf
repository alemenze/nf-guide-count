#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { Fastqc } from '../tools/fastqc/fastqc'
include { Trimgalore } from '../tools/trimgalore/trimgalore'
include { Panda_Stitch } from '../tools/pandaseq/pandaseq'
include { CountGuides } from '../tools/counting/counts'
include { ExtractUnique } from '../tools/counting/unique'
include { Multiqc } from '../tools/multiqc/multiqc'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Processing {
    take:
        reads
        guides

    main:

        Fastqc(
            reads
        )

        Trimgalore(
            reads
        )

        Panda_Stitch(
            Trimgalore.out.reads
        )

        CountGuides(
            Panda_Stitch.out.paired,
            guides
        )

        ExtractUnique(
            Panda_Stitch.out.paired,
            guides
        )

        Multiqc(
            Fastqc.out.zip.collect{ it[1] },
            Trimgalore.out.zip.collect{ it[1] },
            Trimgalore.out.log.collect{ it[1] }
        )

}