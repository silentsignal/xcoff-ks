meta:
  id: xcoff64
  endian: be
doc-ref: https://www.ibm.com/docs/en/aix/7.2?topic=formats-xcoff-object-file-format
seq:
  - id: header
    type: header
  - id: auxiliary_header
    type: auxiliary_header
  - id: hpad0 # TODO
    type: u8
  - id: hpad1
    type: u2
  - id: section_headers
    type: section_header
    size: 72
    repeat: expr
    repeat-expr: header.f_nscns
types:
  header:
    seq:
      - id: f_magic
        size: 2
        contents: [0x01,0xf7]
      - id: f_nscns
        type: u2
      - id: f_timdat
        type: u4
      - id: f_symptr
        type: u8  
      - id: f_opthdr
        type: u2
      - id: f_flags
        type: u2
      - id: f_nsyms
        type: u4
  auxiliary_header:
    seq:
      - id: o_mflag
        type: u2
      - id: o_vstamp
        type: u2
      - id: o_debugger
        type: u4
      - id: o_text_start
        type: u8
      - id: o_data_start
        type: u8
      - id: o_toc
        type: u8
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
      - id: o_textpsize
        type: u1
      - id: o_datapsize
        type: u1
      - id: o_stackpsize # Documentation mismatch! This can't be at the same offset as o_datapsize!
        type: u1
      - id: o_flags
        type: u1        
      - id: o_tsize
        type: u8
      - id: o_dsize
        type: u8
      - id: o_bsize
        type: u8
      - id: o_entry
        type: u8
      - id: o_maxstack
        type: u8
      - id: o_maxdata
        type: u8
      - id: o_sntdata
        type: u2
      - id: o_sntbss
        type: u2
      - id: o_x64flags
        type: u2
  section_header:
    seq:
      - id: s_name
        type: strz
        encoding: ASCII
        size: 8
      - id: s_paddr
        type: u8
      - id: s_vaddr
        type: u8
      - id: s_size
        type: u8
      - id: s_scnptr
        type: u8
      - id: s_relptr
        type: u8
      - id: s_lnnoptr
        type: u8
      - id: s_nreloc
        type: u4
      - id: s_nlnno 
        type: u4
      - id: s_flags_dwraf # Need to split this u4 so we can switch() on the value in Java
        type: u2  
      - id: s_flags
        type: u2   
      - id: spad # See : https://go.googlesource.com/go/+/go1.16.2/src/internal/xcoff/xcoff.go
        type: u4
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
      relocation_table:
        io: _root._io
        pos: s_relptr
        type: section_relocation_table
    enums:
      section_flags: # "The low-order 16 bits specify the primary section type. Only a single bit should be set in the low-order 16 bits."
        0x0: styp_reserved0
        0x1: styp_reserved1
        0x2: styp_reserved2
        0x4: styp_reserved4
        0x8: styp_pad
        0x10: styp_dwarf
        0x20: styp_text
        0x40: styp_data
        0x80: styp_bss
        0x100: styp_except
        0x200: styp_info
        0x400: styp_tdata
        0x800: styp_tbss
        0x1000: styp_loader
        0x2000: styp_debug
        0x4000: styp_typchk
        0x8000: styp_ovrflo
  symbol_table:
    seq:
      - id: symbol_entries
        type: symbol_entry
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
      - id: l_value
        type: u8
      - id: l_nameptr
        type: symbol_name
        size: 4
      - id: l_scnum
        type: u2
      - id: l_smtype
        type: symbol_type
      - id: l_smclas
        type: u1
      - id: l_ifile
        type: u4
      - id: l_param
        type: u4
  symbol_name:
    seq:
      - id: l_offset
        type: u4
    instances:
      l_strname:
        io: _parent._parent._parent.l_string_table._io
        pos:  l_offset
        type: strz
        encoding: ASCII
  symbol_type:
    seq:
      - id: sym_reserved0
        type: b1
      - id: sym_imported
        type: b1
      - id: sym_entrypoint
        type: b1
      - id: sym_exported
        type: b1
      - id: sym_weak
        type: b1
      - id: sym_type
        type: b3
  import_table:
    seq:
      - id: import_entries
        type: import_entry
        repeat: expr
        repeat-expr: _parent.l_nimpid
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
  loader_relocation_table:
    seq:
      - id: relocation_entries
        type: loader_relocation_entry
        repeat: expr
        repeat-expr: _parent.l_nreloc
  section_relocation_table:
    seq:
      - id: relocation_entries
        type: relocation_entry
        repeat: expr
        repeat-expr: _parent.s_nreloc
  loader_relocation_entry:
    seq:
      - id: l_vaddr
        type: u8
      - id: l_value
        type: u2
      - id: l_rsecnm
        type: u2
      - id: l_symndx
        type: u4
      - id: l_rtype # TODO
        type: u4
  relocation_entry:
    seq:
      - id: r_vaddr
        type: u8
      - id: r_symndx
        type: u4
      - id: r_size
        type: u1
      - id: r_rtype
        type: u1
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
      - id: l_stlen
        type: u4
      - id: l_impoff
        type: u8
      - id: l_stoff
        type: u8
      - id: l_symoff
        type: u8
      #- id: l_dummy0 # 16 byte gap according to docs, but I don't get sensible results
      #  type: u8
      #- id: l_dummy1
      #  type: u8
      - id: l_rldoff
        type: u4
    instances:
      l_symbol_table:
        io: _io
        pos: l_symoff
        type: symbol_table
      l_string_table:
        io: _io
        pos: l_stoff
        type: string_table
        size: l_stlen
      l_import_table:
        io: _io
        pos: l_impoff
        type: import_table
      l_reloc_table:
        io: _io
        pos: l_rldoff
        type: loader_relocation_table
        if: l_rldoff != 0
  common_section:
    seq:
      - id: body
        size: _parent.s_size
