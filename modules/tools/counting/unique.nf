// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process ExtractUnique {
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/unique_counts",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    input:
        tuple val(meta), path(stitched_reads)
        val guides

    output:
        tuple val(meta), path("*_unique_sequences.csv"), emit: uniqueSeqs

    script:
        """
        echo "Label,String,Upstream-Downstream Sequence,Count" > ${meta}_unique_sequences.csv
        while IFS=, read -r label guide; do
            grep -B1 -A1 "\$guide" ${stitched_reads} | awk -v label="\$label" -v str="\$guide" '
            BEGIN { FS = "" }
            {
                if (NR % 4 == 2) {
                    match(\$0, str);
                    if (RSTART > 26 && (RLENGTH + RSTART + 28 - 1) <= length(\$0)) {
                        upstream = substr(\$0, RSTART - 26, 26);
                        downstream = substr(\$0, RSTART + RLENGTH, 28);
                        sequence = upstream downstream;
                        sequence_counts[sequence]++;
                    }
                }
            }
            END {
                for (seq in sequence_counts) {
                    print label "," str "," seq "," sequence_counts[seq];
                }
            }' >> temp_sequences.csv
        done <<< "\$(printf "%s\n" ${guides.collect().join('\n')})"

        # Consolidate counts for unique sequences
        awk -F, '{count[\$3] += \$4} END {for (seq in count) print seq "," count[seq]}' temp_sequences.csv > ${meta}_unique_sequences.csv
        rm -f temp_sequences.csv
        """
}