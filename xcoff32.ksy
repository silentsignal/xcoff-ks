meta:
  id: xcoff32
  endian: be
seq:
  - id: header
    type: header
  - id: auxiliary_header
    type: auxiliary_header
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
      - id: s_flags
        type: u2
    instances:
      subsection:
        io: _root._io
        pos: s_scnptr
        size: s_size
        type: 
          switch-on: s_name
          cases:
            '".loader"': loader_section
            _ : common_section
      body:
        io: _root._io
        pos: s_scnptr
        size: s_size
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
        size: l_nsyms*24
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
        
instances:
  section_headers:
    pos: 92
    size: 40
    repeat: expr
    repeat-expr: header.f_nscns
    type: section_header
  
