vcs \
bitonic_sort_tb.v \
bitonic_sort_syn.v \
-R -full64 \
-v /cad/CBDK018_UMC_Faraday_v1.1/CIC/Verilog/fsa0m_a_generic_core_21.lib.src \
-v /cad/CBDK018_UMC_Faraday_v1.1/CIC/Verilog/fsa0m_a_t33_generic_io_21.lib.src \
-sverilog \
-debug_access+all \
+v2k \
+neg_tchk \
+define+GATE \
-l gate_sim.log
