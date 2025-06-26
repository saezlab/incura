# InCURA <img src="data/Logo_incura.jpg" align="right" width="120" />
## Integrative Gene Clustering on Transcription Factor Binding Sites 

### Concept
Biologically meaningful interpretation of transcriptomic datasets remains challenging, particularly when context-specific gene sets are either unavailable or too generic to capture the underlying biology. We present InCURA, an integrative clustering strategy based on transcription factor (TF) motif occurrence patterns in gene promoters. InCURA relies on a user-friendly input of lists of (i) all expressed genes, used to identify dataset-specific TFs, and (ii) differentially expressed genes (DEGs). Promoter sequences of DEGs are scanned for TF binding motifs, and the resulting counts are compiled into a gene-by-TF matrix. InCURA then uses unsupervised clustering to infer gene modules with shared predicted regulatory input. Employing InCURA to diverse biological datasets, we uncovered functionally coherent gene modules revealing upstream regulators and regulatory programs that standard enrichment or co-expression analyses, such as WGCNA, fail to detect. Together, InCURA provides a regulation-centric tool for dissecting transcriptional responses for fundamental biological discovery research, particularly in settings lacking context-specific gene sets.

### Usage
