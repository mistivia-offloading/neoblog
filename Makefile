SRCDIR := .
BUILDDIR := output

TXT_FILES := $(shell find $(SRCDIR) -name "*.md" ! -path "$(BUILDDIR)*")
TYP_FILES := $(shell find $(SRCDIR) -name "*index.typ" ! -path "$(BUILDDIR)*")
TEX_FILES := $(shell find $(SRCDIR) -name "*index.tex" ! -path "$(BUILDDIR)*")

BUILD_TARGETS := $(patsubst $(SRCDIR)/%.md,$(BUILDDIR)/%.html,$(TXT_FILES))
TYP_TARGETS := $(patsubst $(SRCDIR)/%.typ,$(BUILDDIR)/%.html,$(TYP_FILES))
TEX_TARGETS := $(patsubst $(SRCDIR)/%.tex,$(BUILDDIR)/%.html,$(TEX_FILES))

.PHONY: all clean

all: $(BUILD_TARGETS) $(TYP_TARGETS) $(TEX_TARGETS)

$(BUILD_TARGETS):$(BUILDDIR)/%.html: $(SRCDIR)/%.md
	@mkdir -p $(@D)
	python process.py $< > $@

$(TYP_TARGETS):$(BUILDDIR)/%.html: $(SRCDIR)/%.typ
	@mkdir -p $(@D)
	python typ2html.py $<

$(TEX_TARGETS):$(BUILDDIR)/%.html: $(SRCDIR)/%.tex
	@mkdir -p $(@D)
	python tex2html.py $<

clean:
	-rm -rf $(BUILD_TARGETS) $(TYP_TARGETS) $(TEX_TARGETS)
