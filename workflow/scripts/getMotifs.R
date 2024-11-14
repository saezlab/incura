library(MotifDb)


# Parse args
args <- commandArgs(trailingOnly = F)
path_tfs <- args[6]
organism <- args[7]
path_out <- args[8]

nCores <- 4

print(args)

tfs <- read.table(path_tfs)

indices <- c()

for (tf in tfs){
    pattern <- paste("^", tf, "$", sep="")
    indices <- append(indices, grep(pattern, values(MotifDb)$geneSymbol, ignore.case=TRUE))
}

all.motifs <- MotifDb[indices]

if (organism == "Hsapiens") {
   filt.motifs <- subset(all.motifs, organism=="Hsapiens")
} else if (organism == "Mmusculus") {
   filt.motifs <- subset(all.motifs, organism=="Mmusculus")
} else {
   print("Error: Invalid organism. Only Hsapiens or Mmusculus")
}

export(filt.motifs, con=path_out, format="meme")


 
