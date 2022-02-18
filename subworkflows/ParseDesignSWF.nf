include { ParseDesign } from '../modules/ParseDesign.nf'

workflow ParseDesignSWF {
    take:
        design

    main:
        ParseDesign(design)
            .csv
            .splitCsv(header:true, sep:',')
            .map { createReadsChannel(it) }
            .set { rawReads }

    emit:
        rawReads
}


// create a list of data from the csv
def createReadsChannel(LinkedHashMap row) {
    // store metadata in a Map
    def metadata = [:]
    metadata.libID      = row.lib_ID
    metadata.sampleName = row.sample_rep
    metadata.readType   = row.fq2 ? 'doubleEnd' : 'singleEnd'

    // store reads in a list
    def reads = []
    if (metadata.readType == 'singleEnd') {
        reads = [file(row.fq1)]
    } else {
        reads = [file(row.fq1), file(row.fq2)]
    }

    // check that reads files exist
    reads.each {
        if (!it.exists()) {
            exit 1, "ERROR: ${it} does not exist!"
        }
    }

    return [metadata, reads]
}