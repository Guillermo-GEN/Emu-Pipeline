#!/bin/sh

# Function to find and initialize conda (sh-compatible)
init_conda() {
  # Check common conda installation paths one by one
  if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: $HOME/anaconda3/etc/profile.d/conda.sh"
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
    return 0
  elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: $HOME/miniconda3/etc/profile.d/conda.sh"
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
    return 0
  elif [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: $HOME/miniforge3/etc/profile.d/conda.sh"
    . "$HOME/miniforge3/etc/profile.d/conda.sh"
    return 0
  elif [ -f "$HOME/mambaforge/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: $HOME/mambaforge/etc/profile.d/conda.sh"
    . "$HOME/mambaforge/etc/profile.d/conda.sh"
    return 0
  elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: /opt/anaconda3/etc/profile.d/conda.sh"
    . "/opt/anaconda3/etc/profile.d/conda.sh"
    return 0
  elif [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
    echo "Found conda at: /opt/miniconda3/etc/profile.d/conda.sh"
    . "/opt/miniconda3/etc/profile.d/conda.sh"
    return 0
  elif command -v conda >/dev/null 2>&1; then
    CONDA_BASE=$(conda info --base 2>/dev/null)
    if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
      echo "Found conda at: $CONDA_BASE/etc/profile.d/conda.sh"
      . "$CONDA_BASE/etc/profile.d/conda.sh"
      return 0
    fi
  fi

  echo "Error: Could not find conda installation"
  return 1
}

# Initialize conda
if init_conda; then
  # Activate your environment
  conda activate emu
  echo "Using environment: $CONDA_DEFAULT_ENV"
  emu --version

  ##############################
  ### Exportando variables correspondientes a los directorios a trabajar
  LOCATION="$(cd -- "$(dirname -- "$0")" && pwd)"
  EMU_DATABASE_DIR=$LOCATION/database
  EMU_DEFAULT_RESULTS=$LOCATION/results
  RAW_DATA=$LOCATION/raw_data

  cd $RAW_DATA

  ### --keep-counts es variable booleana al añadir el argumento cambia de FALSE a TRUE##
  for i in *fastq; do
    emu abundance --db $EMU_DATABASE_DIR $i --keep-counts --output-dir $EMU_DEFAULT_RESULTS --threads 3
  done

  wait

  ### Combinacion de resultados y separacion de las tablas en matrices
  ### DEFAULT
  emu combine-outputs --split-tables "${EMU_DEFAULT_RESULTS}" species
  emu combine-outputs --counts --split-tables "${EMU_DEFAULT_RESULTS}" species
  echo done
else
  echo "Please install Anaconda or Miniconda first"
  exit 1
fi
