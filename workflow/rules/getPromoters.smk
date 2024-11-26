rule extractPromoters:
    input:
        genome='data/genome.fa',
        annot='data/annot.gtf'
    output:
        db='data/gff.db',
        promoters='data/promoters.csv'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        echo "Extracting promoters..."
        get_promoter create -g {input.annot} && mv gff.db data/
        get_promoter extract -l 2000 -u 500 -f {input.genome} -g {output.db} -o {output.promoters}
        """

rule extractGenes:
    input:
        annot="data/annot.gtf"
    output:
        ids='data/ids2names.tsv',
        ids_sorted='data/ids2names.sorted.tsv'
    shell:
        """
        echo "Retreiving gene names..."
        cat {input.annot} | awk 'BEGIN{{FS="\t"}} {{split($9,a,";"); if($3~"gene") print a[1]"\t"a[3]}}' | sed 's/gene_id "//' | sed 's/gene_name "//' | sed 's/"//g' > {output.ids}
        sort {output.ids} > {output.ids_sorted}
        """

rule sortPromoters:
    input:
        promoters="data/promoters.csv"
    output:
        prom_cleaned='data/promoters.cleaned.csv',
        prom_sorted='data/promoters.sorted.csv',
    shell:
        """
        echo "Sorting promoters..."
        tail -n +2 {input.promoters} > {output.prom_cleaned}
        sort {output.prom_cleaned} > {output.prom_sorted}
        """

rule convertPromoters:
    input:
        prom_sorted='data/promoters.sorted.csv'
    output:
        prom_tsv='data/promoters.sorted.tsv'

    shell:
        """
        echo "Converting promoters..."
        sed -E 's/("([^"]*)")?,/\2\t/g' {input.prom_sorted} > {output.prom_tsv}
        """

rule annotPromoters:
    input:
        prom_tsv='data/promoters.sorted.tsv',
        ids_sorted='data/ids2names.sorted.tsv'
    output:
        prom_updated='data/promoters.sorted.updated.tsv'
        prom_annot='data/promoters.annot.tsv'

    shell:
        """
        echo "Assigning gene names..."
        sed 's/[^[:print:]\t]//g' {input.prom_tsv} > {output.prom_updated}
        awk 'NR==FNR {{id[$1]=$2; next}} {{if ($1 in id) $1=id[$1]; print}}' {input.ids_sorted} {output.prom_updated} > {output.prom_annot}
        """

rule filterPromoters:
    input:
        DEGS='data/sharedDEGs_mm10.txt',
        prom_annot='data/promoters.annot.tsv'
    output:
        prom_filt='data/promoters.filt.tsv'
    shell:
        """
        echo "Filtering promoters..."
        grep -Ff {input.DEGS} {input.prom_annot} > {output.prom_filt}
        """


rule formatPromoters:
    input:
        prom_filt='data/promoters.filt.tsv'
    output:
        promoters='data/promoters.formatted.tsv'
    shell:
        """
        echo "Formatting promoters..."
        awk -F' ' 'BEGIN {{OFS=" "}} {{print $2, $3, $4, $5, $1, $6}}' {input.prom_filt} > {output.promoters}
        sed -e 's/^/chr/' -i {output.promoters}

        echo "Done."
        """

rule createFasta:
    input:
        tsv='data/promoters.formatted.tsv'
    output:
        fasta='data/promoters.fa'
    shell:
        """
        echo "Creating FASTA file..."
        awk -F' ' 'NR>1 {{print ">"$1":"$2"-"$3"("$4")_"$5"\n"$6}}' {input.tsv} > {output.fasta}
        """