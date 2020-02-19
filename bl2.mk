$(info "======= bl2.mk enter =========")

BL2_BIN := $(PRODUCT_OUT)/pyrope-bl2.bin

$(BL2_BIN):
	$(hide) echo "=========== BL2 Building !!! =========="
	$(MAKE) -C $(TARGET_BL2_SRC) clean;
	$(MAKE) -C $(TARGET_BL2_SRC)  SUPPORT_OTA_AB_UPDATE=y;
	$(shell cp -af $(TARGET_BL2_SRC)/out/pyrope-bl2.bin $(BL2_BIN));

.PHONY : $(BL2_BIN)

bl2image: $(BL2_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(BL2_BIN)


$(info "======= bl2.mk exit =========")
