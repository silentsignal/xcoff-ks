meta:
  id: traceback_table
  endian: be
  bit-endian: be
doc-ref: https://refspecs.linuxfoundation.org/ELF/ppc64/PPC-elf64abi.html#TRACEBACK
seq:
  - id: marker
    size: 4
    contents: [0, 0, 0, 0]
  - id: mandatory_fields
    type: mandatory_fields
  - id: optional_fields
    type: optional_fields
types:
  mandatory_fields:
    seq:
      - id: version
        type: u1
      - id: lang
        type: u1
        enum: lang
      - id: globalink
        type: b1
      - id: is_eprol
        type: b1
      - id: has_tboff
        type: b1
      - id: int_proc
        type: b1
      - id: has_ctl
        type: b1
      - id: tocless
        type: b1
      - id: fb_present
        type: b1
      - id: log_abort
        type: b1
      - id: int_handl
        type: b1
      - id: name_present
        type: b1
      - id: uses_alloca
        type: b1
      - id: cl_dis_inv
        type: b3
      - id: saves_cr
        type: b1
      - id: saves_lr
        type: b1
      - id: stores_bc
        type: b1
      - id: fixup
        type: b1
      - id: fp_saved
        type: b6
      - id: has_vec_info
        type: b1
      - id: spare4
        type: b1
      - id: gpr_saved
        type: b6
      - id: fixedparms
        type: b8
      - id: floatparms
        type: b7
      - id: parmsonstk
        type: b1
  optional_fields:
    seq:
      - id: parminfo
        if: _parent.mandatory_fields.fixedparms != 0 or _parent.mandatory_fields.floatparms != 0
        type: u4
      - id: tb_offset
        if: _parent.mandatory_fields.has_tboff
        type: u4
      - id: hand_mask
        if: _parent.mandatory_fields.int_handl 
        type: u4
      - id: ctl_info
        type: u4
        if: _parent.mandatory_fields.has_ctl 
      - id: ctl_info_disp
        if: _parent.mandatory_fields.has_ctl 
        type: u4
      - id: name_struct
        if: _parent.mandatory_fields.name_present
        type: name_struct
      - id: alloca_reg
        type: u1
        if: _parent.mandatory_fields.uses_alloca
      - id: vr_saved
        type: b6
      - id: saves_vrsave
        type: b1
      - id: has_varargs
        type: b1
      - id: vectorparams
        type: b7
      - id: vec_present
        type: b1
  name_struct:
    seq:
      - id: name_len
        type: u2
      - id: name
        type: str
        size: name_len
        encoding: ASCII

enums:
  lang:
    0: c
    1: fortran
    2: pascal
    3: ada
    4: pl_1
    5: basic
    6: lisp
    7: cobol
    8: modula2
    9: cpp
    10: rpg
    11: pl8_plix
    12: assembly
    13: java
    14: objc
