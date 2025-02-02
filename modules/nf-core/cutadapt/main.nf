process CUTADAPT {
    tag "$meta.id"
    label 'process_medium'

    conda 'bioconda::cutadapt=3.4'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cutadapt:3.4--py39h38f01e4_1' :
        'quay.io/biocontainers/cutadapt:3.4--py39h38f01e4_1' }"

    input:
    tuple val(meta), path(reads), path(adapter_seq)

    output:
    tuple val(meta), path('*.trim.fastq.gz'), optional: true, emit: reads
    tuple val(meta), path('*.log')          , optional: true, emit: log
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (adapter_seq != [])
    """
    cutadapt \\
        --cores $task.cpus \\
        $args \\
        -o ${prefix}.trim.fastq.gz \\
        $reads \\
        > ${prefix}.cutadapt.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """
    else
    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cutadapt: \$(cutadapt --version)
    END_VERSIONS
    """
}
