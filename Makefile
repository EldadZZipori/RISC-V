# ==================================================
# Configuration
# ==================================================

VERILATOR = verilator
BUILD_DIR = .verilator_tmp

# Ordering: package before RTL
PKG = rtl/src/pkg.sv
RTL = $(PKG) $(wildcard rtl/src/*.sv)

# ==================================================
# Targets
# ==================================================

# Perform lint only checks
lint:
	$(VERILATOR) --lint-only --Wall --Mdir $(BUILD_DIR) -Irtl $(RTL)

# Clean output directory (verilator artifacts)
clean:
	rm -rf $(BUILD_DIR)

.PHONY: lint clean