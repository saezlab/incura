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

rule processPromoters:
    input:
        promoters="data/promoters.csv",
        annot="data/annot.gtf",
        DEGS="data/sharedDEGs_mm10.txt"
    output:
        ids='data/ids2names.txt',
        ids_sorted='data/ids2names.sorted.txt',
        prom_cleaned='data/promoters.cleaned.csv',
        prom_sorted='data/promoters.sorted.csv',
        prom_tsv='data/promoters.sorted.tsv',
        prom_annot='data/promoters.annot.tsv',
        prom_filt='data/promoters.final.DE.tsv',
        promoters='data/promoters.formatted.tsv'
    shell:
        """
        echo "Retreiving gene names..."
        cat annot.gtf | awk 'BEGIN{{FS="\t"}}{{split($9,a,";"); if($3~"gene") print a[1]"\t"a[3]}}' | sed 's/gene_id "//' | sed 's/gene_name "//' | sed 's/"//g' > {output.ids}
        sort {output.ids} > {output.ids_sorted}

        echo "Sorting promoters..."
        tail -n +2 {input.promoters} > {prom_cleaned}
        sort {prom_cleaned} > {prom_sorted}

        echo "Converting promoters..."
        sed -E 's/("([^"]*)")?,/\2\t/g' {prom_sorted} > {prom_tsv}

        echo "Assigning gene names..."
        awk 'NR==FNR {{id[$1]=$2; next}} {{if ($1 in id) $1=id[$1]; print}}' {ids_sorted} {prom_tsv} > {prom_annot}

        echo "Filtering promoters..."
        grep -Ff {input.DEGS} {prom_annot} > {prom_filt}

        echo "Formatting promoters..."
        awk -F' ' 'BEGIN {{OFS=" "}} {{print $2, $3, $4, $5, $1, $6}}' {prom_filt} > {output.promoters}
        sed -e 's/^/chr/' -i {output.promoters}

        echo "Done."
        """

rule createFasta:
    input:
        tsv="data/promoters.formatted.tsv",
    output:
        fasta="data/promoters.fa"
    shell:
        """
        echo "Creating FASTA file..."
        awk -F' ' 'NR>1 {{print ">"$1":"$2"-"$3"("$4")_"$5"\n"$6}}' {input.tsv} > {output.fasta}
        """