{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Visual Studio Code
  # ---------------------------------------------------------------------------

  programs.vscode = {
    enable = true;

    package = pkgs.vscode;

    # -------------------------------------------------------------------------
    # Extensions
    # -------------------------------------------------------------------------

    profiles.default.extensions = with pkgs.vscode-extensions; [
      # -----------------------------------------------------------------------
      # Nix
      # -----------------------------------------------------------------------

      jnoortheen.nix-ide

      # -----------------------------------------------------------------------
      # Git / GitHub
      # -----------------------------------------------------------------------

      eamodio.gitlens
      github.vscode-github-actions

      # -----------------------------------------------------------------------
      # Docker
      # -----------------------------------------------------------------------

      ms-azuretools.vscode-docker

      # -----------------------------------------------------------------------
      # Kubernetes
      # -----------------------------------------------------------------------

      ms-kubernetes-tools.vscode-kubernetes-tools

      # -----------------------------------------------------------------------
      # Terraform
      # -----------------------------------------------------------------------

      hashicorp.terraform

      # -----------------------------------------------------------------------
      # Python
      # -----------------------------------------------------------------------

      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy

      # -----------------------------------------------------------------------
      # JavaScript / TypeScript
      # -----------------------------------------------------------------------

      dbaeumer.vscode-eslint
      esbenp.prettier-vscode

      # -----------------------------------------------------------------------
      # Go
      # -----------------------------------------------------------------------

      golang.go

      # -----------------------------------------------------------------------
      # Rust
      # -----------------------------------------------------------------------

      rust-lang.rust-analyzer

      # -----------------------------------------------------------------------
      # C / C++
      # -----------------------------------------------------------------------

      ms-vscode.cpptools
      ms-vscode.cmake-tools

      # -----------------------------------------------------------------------
      # .NET / C#
      # -----------------------------------------------------------------------

      ms-dotnettools.csharp

      # -----------------------------------------------------------------------
      # Shell
      # -----------------------------------------------------------------------

      timonwong.shellcheck

      # -----------------------------------------------------------------------
      # YAML
      # -----------------------------------------------------------------------

      redhat.vscode-yaml

      # -----------------------------------------------------------------------
      # Markdown
      # -----------------------------------------------------------------------

      yzhang.markdown-all-in-one

      # -----------------------------------------------------------------------
      # Editor quality-of-life
      # -----------------------------------------------------------------------

      usernamehw.errorlens
      streetsidesoftware.code-spell-checker
    ];

    # -------------------------------------------------------------------------
    # VS Code Settings
    # -------------------------------------------------------------------------

    profiles.default.userSettings = {
      # -----------------------------------------------------------------------
      # Editor
      # -----------------------------------------------------------------------

      "editor.fontFamily" = "'FiraCode Nerd Font', 'JetBrainsMono Nerd Font', monospace";

      "editor.fontLigatures" = true;

      "editor.fontSize" = 14;

      "editor.lineHeight" = 22;

      "editor.tabSize" = 2;

      "editor.insertSpaces" = true;

      "editor.detectIndentation" = true;

      "editor.formatOnSave" = true;

      "editor.formatOnPaste" = true;

      "editor.formatOnType" = false;

      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        "source.organizeImports" = "explicit";
      };

      "editor.minimap.enabled" = true;

      "editor.bracketPairColorization.enabled" = true;

      "editor.guides.bracketPairs" = true;

      "editor.guides.indentation" = true;

      "editor.renderWhitespace" = "selection";

      "editor.renderControlCharacters" = true;

      "editor.rulers" = [
        80
        100
        120
      ];

      "editor.smoothScrolling" = true;

      "editor.cursorSmoothCaretAnimation" = "on";

      "editor.stickyScroll.enabled" = true;

      "editor.linkedEditing" = true;

      # -----------------------------------------------------------------------
      # Appearance
      # -----------------------------------------------------------------------

      "workbench.colorTheme" = "Default Dark Modern";

      "workbench.preferredDarkColorTheme" = "Default Dark Modern";

      "window.autoDetectColorScheme" = true;

      "workbench.startupEditor" = "none";

      "workbench.tree.indent" = 16;

      "workbench.editor.enablePreview" = false;

      # -----------------------------------------------------------------------
      # Terminal
      # -----------------------------------------------------------------------

      "terminal.integrated.defaultProfile.linux" = "zsh";

      "terminal.integrated.fontFamily" = "FiraCode Nerd Font";

      "terminal.integrated.fontSize" = 13;

      "terminal.integrated.fontLigatures.enabled" = true;

      "terminal.integrated.scrollback" = 20000;

      "terminal.integrated.smoothScrolling" = true;

      "terminal.integrated.profiles.linux" = {
        "zsh" = {
          "path" = "${pkgs.zsh}/bin/zsh";
        };
      };

      # -----------------------------------------------------------------------
      # Files
      # -----------------------------------------------------------------------

      "files.autoSave" = "afterDelay";

      "files.autoSaveDelay" = 1000;

      "files.trimTrailingWhitespace" = true;

      "files.insertFinalNewline" = true;

      "files.trimFinalNewlines" = true;

      "files.exclude" = {
        "**/.git" = true;
        "**/.DS_Store" = true;
        "**/node_modules" = true;
        "**/.direnv" = true;
        "**/.terraform" = true;
        "**/target" = true;
      };

      "files.watcherExclude" = {
        "**/.git/objects/**" = true;
        "**/.git/subtree-cache/**" = true;
        "**/node_modules/**" = true;
        "**/.direnv/**" = true;
        "**/.terraform/**" = true;
        "**/target/**" = true;
      };

      # -----------------------------------------------------------------------
      # Search
      # -----------------------------------------------------------------------

      "search.exclude" = {
        "**/node_modules" = true;
        "**/.direnv" = true;
        "**/.terraform" = true;
        "**/target" = true;
        "**/dist" = true;
        "**/build" = true;
      };

      "search.useIgnoreFiles" = true;

      # -----------------------------------------------------------------------
      # Git
      # -----------------------------------------------------------------------

      "git.enableSmartCommit" = true;

      "git.autofetch" = true;

      "git.confirmSync" = false;

      "git.pruneOnFetch" = true;

      "git.openRepositoryInParentFolders" = "always";

      # -----------------------------------------------------------------------
      # GitHub
      # -----------------------------------------------------------------------

      "github.gitProtocol" = "ssh";

      # -----------------------------------------------------------------------
      # Nix
      # -----------------------------------------------------------------------

      "nix.enableLanguageServer" = true;

      "nix.serverPath" = "nil";

      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [
              "nixfmt"
            ];
          };
        };
      };

      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";

        "editor.formatOnSave" = true;
      };

      # -----------------------------------------------------------------------
      # TypeScript / JavaScript
      # -----------------------------------------------------------------------

      "typescript.updateImportsOnFileMove.enabled" = "always";

      "javascript.updateImportsOnFileMove.enabled" = "always";

      "typescript.preferences.importModuleSpecifier" = "non-relative";

      "javascript.preferences.importModuleSpecifier" = "non-relative";

      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[javascriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "[jsonc]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # -----------------------------------------------------------------------
      # Python
      # -----------------------------------------------------------------------

      "python.defaultInterpreterPath" = "python3";

      "python.terminal.activateEnvironment" = true;

      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "editor.formatOnSave" = true;
      };

      # -----------------------------------------------------------------------
      # Go
      # -----------------------------------------------------------------------

      "[go]" = {
        "editor.formatOnSave" = true;

        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      "go.toolsManagement.autoUpdate" = false;

      # -----------------------------------------------------------------------
      # Rust
      # -----------------------------------------------------------------------

      "rust-analyzer.check.command" = "clippy";

      "rust-analyzer.cargo.allFeatures" = true;

      # -----------------------------------------------------------------------
      # C / C++
      # -----------------------------------------------------------------------

      "C_Cpp.default.cppStandard" = "c++23";

      "C_Cpp.default.cStandard" = "c23";

      "C_Cpp.intelliSenseEngine" = "default";

      # -----------------------------------------------------------------------
      # Terraform
      # -----------------------------------------------------------------------

      "[terraform]" = {
        "editor.defaultFormatter" = "hashicorp.terraform";

        "editor.formatOnSave" = true;
      };

      "[terraform-vars]" = {
        "editor.defaultFormatter" = "hashicorp.terraform";

        "editor.formatOnSave" = true;
      };

      # -----------------------------------------------------------------------
      # YAML
      # -----------------------------------------------------------------------

      "[yaml]" = {
        "editor.defaultFormatter" = "redhat.vscode-yaml";

        "editor.formatOnSave" = true;
      };

      "yaml.validate" = true;

      "yaml.format.enable" = true;

      # -----------------------------------------------------------------------
      # Shell
      # -----------------------------------------------------------------------

      "shellcheck.enable" = true;

      # -----------------------------------------------------------------------
      # Kubernetes
      # -----------------------------------------------------------------------

      "vs-kubernetes" = {
        "vs-kubernetes.kubectl-path" = "kubectl";
        "vs-kubernetes.helm-path" = "helm";
      };

      # -----------------------------------------------------------------------
      # Security / privacy
      # -----------------------------------------------------------------------

      "telemetry.telemetryLevel" = "off";

      "redhat.telemetry.enabled" = false;

      # -----------------------------------------------------------------------
      # Updates
      # -----------------------------------------------------------------------
      #
      # Nix controls the installed VS Code version and extensions.
      #

      "update.mode" = "none";

      "extensions.autoUpdate" = false;

      "extensions.autoCheckUpdates" = false;
    };
  };

  # ---------------------------------------------------------------------------
  # VS Code support packages
  # ---------------------------------------------------------------------------

  home.packages = with pkgs; [
    # Nix language server / formatter
    nil
    nixfmt

    # Shell diagnostics
    shellcheck
    shfmt

    # Search / editor helpers
    ripgrep
    fd
  ];
}
