#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process bff{
    publishDir "$projectDir/$params.outdir/${seurat_object.name.tokenize( '_' )[1]}/$params.mode/hash_demulti/bff", mode:'copy'
    label 'small_mem'
    input:
       
        tuple val(sampleId), path(hto_matrix, stageAs: 'hto_data'),
        each methods
        each methodsForConsensus
        each cellbarcodeWhitelist
        each metricsFile
        each doTSNE
        each doHeatmap
        each perCellSaturation
        each majorityConsensusThreshold
        each chemistry
        each callerDisagreementThreshold
        each assignmentOutBff
        each preprocess_bff
        each barcodeWhitelist
        
    output:
        path "bff_${sampleId}"
        
        
    script:
        def sampleId = seurat_object.name.tokenize( '_' )[1]

        """
        mkdir bff_${sampleId}
        bff.R --fileHto hto_data --methods $methods --methodsForConsensus $methodsForConsensus \
        --cellbarcodeWhitelist $cellbarcodeWhitelist --cellbarcodeWhitelist $cellbarcodeWhitelist --metricsFile bff_${task.index}_$metricsFile \
        --doTSNE $doTSNE --doHeatmap $doHeatmap --perCellSaturation $perCellSaturation --majorityConsensusThreshold $majorityConsensusThreshold \
        --chemistry $chemistry --callerDisagreementThreshold $callerDisagreementThreshold --outputdir bff_${sampleId} --assignmentOutBff $assignmentOutBff \ 
        --preprocess $preprocess_bff --barcodeWhitelist $barcodeWhitelist
        """

}

def split_input(input){
    if (input =~ /;/ ){
        Channel.from(input).map{ return it.tokenize(';')}.flatten()
    }
    else{
        Channel.from(input)
    }
}

workflow bff_hashing{
  take: 
        hto_matrix
  main:
        methods = split_input(params.methods)
        methodsForConsensus = split_input(params.methodsForConsensus)
        cellbarcodeWhitelist = split_input(params.cellbarcodeWhitelist)
        metricsFile = split_input(params.metricsFile)
        doTSNE = split_input(params.doTSNE)
        doHeatmap = split_input(params.doHeatmap)
        perCellSaturation = split_input(params.perCellSaturation)
        majorityConsensusThreshold  = split_input(params.majorityConsensusThreshold)
        chemistry = split_input(params.chemistry)
        callerDisagreementThreshold = split_input(params.callerDisagreementThreshold)
        assignmentOutBff = split_input(params.assignmentOutBff)
        preprocess_bff = split_input(params.preprocess_bff)
        barcodeWhitelist = split_input(params.barcodeWhitelist)

        bff(hto_matrix, methods, methodsForConsensus, metricsFile,cellbarcodeWhitelist,doTSNE,doHeatmap,perCellSaturation,majorityConsensusThreshold,chemistry,callerDisagreementThreshold,assignmentOutBff,preprocess_bff,barcodeWhitelist)
  
  emit:
        bff.out.collect()
}


workflow{
    bff_hashing()

}