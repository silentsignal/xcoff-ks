meta:
  id: xcoff32
  endian: be
doc-ref: https://www.ibm.com/docs/en/aix/7.2?topic=formats-xcoff-object-file-format
seq:
  - id: header
    type: header
  - id: auxiliary_header
    type: auxiliary_header
  - id: section_headers
    type: section_header
    size: 40
    repeat: expr
    repeat-expr: header.f_nscns
types:
  header:
    seq:
      - id: f_magic
        size: 2
        contents: [0x01,0xdf]
      - id: f_nscns
        type: u2
      - id: f_timdat
        type: u4
      - id: f_symptr
        type: u4
      - id: f_nsyms
        type: u4
      - id: f_opthdr
        type: u2
      - id: f_flags
        type: u2
  auxiliary_header:
    seq:
      - id: o_mflag
        type: u2
      - id: o_vstamp
        type: u2
      - id: o_tsize
        type: u4
      - id: o_dsize
        type: u4
      - id: o_bsize
        type: u4
      - id: o_entry
        type: u4
      - id: o_text_start
        type: u4
      - id: o_data_start
        type: u4
      - id: o_toc
        type: u4
      - id: o_snentry
        type: u2
      - id: o_sntext
        type: u2
      - id: o_sndata
        type: u2
      - id: o_sntoc
        type: u2
      - id: o_snloader
        type: u2
      - id: o_snbss
        type: u2
      - id: o_algntext
        type: u2
      - id: o_algndata
        type: u2
      - id: o_modtype
        type: u2
      - id: o_cpuflag
        type: u1
      - id: o_cputype
        type: u1
      - id: o_maxstack
        type: u4
      - id: o_maxdata
        type: u4
      - id: o_debugger
        type: u4
      - id: o_textpsize
        type: u1
      - id: o_datapsize
        type: u1
      - id: o_stackpsize
        type: u1
      - id: o_flags
        type: u1
      - id: o_sntdata
        type: u2
      - id: o_sntbss
        type: u2
  section_header:
    seq:
      - id: s_name
        type: strz
        encoding: ASCII
        size: 8
      - id: s_paddr
        type: u4
      - id: s_vaddr
        type: u4
      - id: s_size
        type: u4
      - id: s_scnptr
        type: u4
      - id: s_relptr
        type: u4
      - id: s_lnnoptr
        type: u4
      - id: s_nreloc
        type: u2
      - id: s_nlnno
        type: u2
      - id: s_dummy # Wrong documentation, see also: https://go.googlesource.com/go/+/go1.16.2/src/internal/xcoff/xcoff.go
        type: u2
      - id: s_flags
        type: u2    
    instances:
      subsection:
        io: _root._io
        pos: s_scnptr
        size: s_size
        type: 
          switch-on: s_flags # TODO need an enum or something... https://github.com/kaitai-io/kaitai_struct/issues/597
          cases:
            0x1000: loader_section 
            _ : common_section
        if: s_scnptr != 0
      body:
        io: _root._io
        pos: s_scnptr
        size: s_size
        if: s_scnptr != 0
  loader_section:
    seq:
      - id: l_version
        type: u4
      - id: l_nsyms
        type: u4
      - id: l_nreloc
        type: u4
      - id: l_istlen
        type: u4
      - id: l_nimpid
        type: u4
      - id: l_impoff
        type: u4
      - id: l_stlen
        type: u4
      - id: l_stoff
        type: u4
      - id: symbol_table # We need this to open a new stream for l_name
        type: symbol_table
      - id: reloc_table
        type: relocation_table
      - id: import_table
        type: import_table
        size: l_istlen
      - id: string_table
        type: string_table
        size: l_stlen
  common_section:
    seq:
      - id: body
        size: _parent.s_size
  symbol_table:
    seq:
      - id: symbol_entries
        type: symbol_entry
        size: 24
        repeat: expr
        repeat-expr: _parent.l_nsyms
  string_table:
    seq:
      - id: string_entries
        type: string_entry
        repeat: eos
  string_entry:
    seq:
      - id: strlen
        type: u2
      - id: str
        type: strz
        encoding: ASCII
        size: strlen
  symbol_entry:
    seq:
      - id: name_structure
        type: symbol_name
        size: 8 
      - id: l_value
        type: u4
      - id: l_scnum
        type: u2
      - id: l_smtype
        type: u1
      - id: l_smclas
        type: u1
      - id: l_ifile
        type: u4
      - id: l_param
        type: u4
  symbol_name:
    seq:
      - id: l_zeroes
        type: u4
      - id: l_offset
        type: u4
    instances:
      l_name:
        pos: 0
        type: strz
        encoding: ASCII
        size: 8
      l_strname:
        io: _parent._parent._parent.string_table._io
        pos:  l_offset
        type: strz
        encoding: ASCII
        if: l_zeroes == 0
  relocation_table:
    seq:
      - id: relocation_entries
        type: relocation_entry
        repeat: expr
        repeat-expr: _parent.l_nreloc
  relocation_entry:
    seq:
      - id: l_vaddr
        type: u4
      - id: l_symndx
        type: u4
      #- id: l_rtype # TODO
      #  type: u4
      - id: l_value
        type: u2
      - id: l_rsecnm
        type: u2
  import_table:
    seq:
      - id: import_entries
        type: import_entry
        repeat: eos
  import_entry:
    seq:
      - id: l_impidpath
        type: strz
        encoding: ASCII
      - id: l_impidbase
        type: strz
        encoding: ASCII
      - id: l_impidmem
        type: strz
        encoding: ASCII        

  
