
ORGANISM = config['organism']
print(ORGANISM)

# Define input functions
#----------------------------------------------------------
# Input function for species specific reference genome files

def get_TFs(wildcards):
    if ORGANISM == 'Hsapiens':
        TFs = config['data']['url']['TFs_hg38']
    elif ORGANISM == 'Mmusculus':
        TFs = config['data']['url']['TFs_mm10']
    return [TFs]
#-----------------------------------------------------------
# Input function to download genome 

def get_genome(wildcards):
    if ORGANISM == 'Hsapiens':
        genome = config['data']['url']['genome_hg38']
        annot = config['data']['url']['annot_hg38']
    elif ORGANISM == 'Mmusculus':
        genome = config['data']['url']['genome_mm10']
        annot = config['data']['url']['annot_mm10']
    return [genome, annot]

#-----------------------------------------------------------

rule installMEME:
    output:
        index='software/meme-5.5.7.tar.gz'
    params:
        meme=config['software']['url']['meme']
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        wget '{params.meme}' -O '{output.index}'
        tar zxf {output.index}
        (cd software/meme-5.5.7 && ./configure --prefix=$HOME/meme --enable-build-libxml2 --enable-build-libxslt && make && make test && make install)
        """


rule downloadTFs:
    input:
        get_TFs
    output:
        tfs='data/all_TFs.txt'
    singularity:
        'workflow/envs/InCURA.sif'
    shell:
        """
        wget '{input[0]}' -O '{output.tfs}'
        """

rule downloadGenome:
    input:
        get_genome:
    output:
    
