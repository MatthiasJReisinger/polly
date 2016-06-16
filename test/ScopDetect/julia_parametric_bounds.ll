; RUN: opt %loadPolly -polly-detect -analyze < %s | FileCheck %s
;
; This test case contains the LLVM IR that Julia has emitted for the following
; code snippet:
;
; function foo(A,l,u)
;     for i=l:u
;         A[i] = 0
;     end
; end
;
; CHECK: Valid Region for Scop: top.split => L2

%jl_value_t = type { %jl_value_t* }

; Function Attrs: sspreq
define void @foo(%jl_value_t*, i64, i64) {
top:
  br label %top.split

top.split:                                        ; preds = %top
  %3 = icmp sgt i64 %1, %2
  %4 = add i64 %1, -1
  %5 = select i1 %3, i64 %4, i64 %2
  %6 = add i64 %5, 1
  %7 = icmp eq i64 %1, %6
  br i1 %7, label %L2, label %if.lr.ph

if.lr.ph:                                         ; preds = %top.split
  br label %if

L.L2_crit_edge:                                   ; preds = %if
  br label %L2

L2:                                               ; preds = %L.L2_crit_edge, %top.split
  ret void

if:                                               ; preds = %if.lr.ph, %if
  %"#temp#.04" = phi i64 [ %1, %if.lr.ph ], [ %8, %if ]
  %8 = add i64 %"#temp#.04", 1
  %9 = add i64 %"#temp#.04", -1
  %10 = bitcast %jl_value_t* %0 to float**
  %11 = load float*, float** %10, align 8
  %12 = getelementptr float, float* %11, i64 %9
  store float 0.000000e+00, float* %12, align 4
  %13 = icmp eq i64 %8, %6
  br i1 %13, label %L.L2_crit_edge, label %if
}
