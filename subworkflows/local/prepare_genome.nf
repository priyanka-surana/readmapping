//
// Uncompress and prepare reference genome files
//

include { GUNZIP                  } from '../../modules/nf-core/modules/gunzip/main'
include { UNTAR as UNTAR_BWAMEM2  } from '../../modules/nf-core/modules/untar/main'
include { BWAMEM2_INDEX           } from '../../modules/nf-core/modules/bwamem2/index/main'
include { UNTAR as UNTAR_MINIMAP2 } from '../../modules/nf-core/modules/untar/main'
include { MINIMAP2_INDEX          } from '../../modules/nf-core/modules/minimap2/index/main'

workflow PREPARE_GENOME {
  main:
  ch_versions = Channel.empty()

  // Uncompress genome fasta file if required
  if (params.fasta.endsWith('.gz')) {
	ch_fasta    = GUNZIP ( [ [:], params.fasta ] ).gunzip.map { it[1] }
	ch_versions = ch_versions.mix(GUNZIP.out.versions)
  } else {
	ch_fasta = file(params.fasta)
  }

  // Generate BWA index
  ch_bwamem2_index = Channel.empty()
  if (params.bwamem2_index) {
        if (params.bwamem2_index.endsWith('.tar.gz')) {
                ch_bwamem2_index = UNTAR_BWAMEM2 (params.bwamem2_index).untar
                ch_versions      = ch_versions.mix(UNTAR_BWAMEM2.out.versions)
        } else {
                ch_bwamem2_index = file(params.bwamem2_index)
        }
  } else {
        ch_bwamem2_index = BWAMEM2_INDEX (ch_fasta).index
        ch_versions      = ch_versions.mix(BWAMEM2_INDEX.out.versions)
  }

  // Generate Minimap2 index
  ch_minimap2_index = Channel.empty()
  if (params.minimap2_index) {
        if (params.minimap2_index.endsWith('.tar.gz')) {
                ch_minimap2_index = UNTAR_MINIMAP2 (params.minimap2_index).untar
                ch_versions       = ch_versions.mix(UNTAR_MINIMAP2.out.versions)
        } else {
                ch_minimap2_index = file(params.minimap2_index)
        }
  } else {
        ch_minimap2_index = MINIMAP2_INDEX (ch_fasta).index
        ch_versions      = ch_versions.mix(MINIMAP2_INDEX.out.versions)
  }

  emit:
  fasta    = ch_fasta                  // path: genome.fa
  bwaidx   = ch_bwamem2_index          // path: bwamem2/index/
  minidx   = ch_minimap2_index         // path: minimap2/index/

  versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}