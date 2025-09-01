# Emu to Biome pipeline

  ## Introduction 

  This is a pipeline that uses the python based **Emu** 16S relative abundance estimator to process full length *Oxford Nanopore* 16S reads for further analysis.

  ## Installation

  ### Requirements
  - Anaconda or Anaconda based python environment manager.
  - Treangenlab Emu **installed under a python 3.7 env called emu**.
  
      [https://github.com/treangenlab/emu](https://github.com/treangenlab/emu)

  - An Emu database.
    
    - [Prebuilt from the Treangenlab OSFUI](https://osf.io/56uf7/files/osfstorage).
    - Pulled through the OSFclient.
    ```bash
    pip install osfclient
    export EMU_DATABASE_DIR=<path_to_database>
    cd ${EMU_DATABASE_DIR}
    osf -p 56uf7 fetch osfstorage/emu-prebuilt/${EMU_PREBUILT_DB}.tar
    tar -xvf ${EMU_PREBUILT_DB}.tar
    ```
    - Custom database as per the instructions in the [Emu github](https://github.com/treangenlab/emu).

  ### Installation proper

  1. Install Anaconda or derived environment manager.
  
  2. Create environment and install Emu.
   ```bash
  conda create --name emu python=3.7 
  conda activate emu
  ```
  3. Install Emu in the environment.
  ```bash
  conda config --add channels defaults
  conda config --add channels bioconda
  conda config --add channels conda-forge
  conda install -c bioconda emu
  ```
  4. Download and extract the pipeline.

  5. Move the Emu database into the database folder inside the main folder.

  ## Usage

  To start processing data place the 16S read data in **.fastq** format inside the raw_data folder and run the **emuabundance_Vx.sh** script. The processed data will be in the results folder ready for further analysis.

  ### Threads and other arguments

  - Emu by default uses 3 threads to process the data with minimap2 you can change this by going to the script and finding this line.
  ```bash
  emu abundance --db $EMU_DATABASE_DIR $i --keep-counts --output-dir $EMU_DEFAULT_RESULTS --threads 3
```
  And changing the number in the --threads argument.

  - You can change the database location by changing the ${EMU_DATABASE_DIR} variable for the desire location
  - This can also be done for the ${EMU_DEFAULT_RESULTS} to change the output directory.

  - Additionally you can add or change different arguments for different abundance estimation parameters.
    
    - You can find additional documentation and parameters at the [Emu github](https://github.com/treangenlab/emu).
    
    - Do not touch the --keep-counts parameter as it is required usually required for further analysis.
    
<details >
  <summary><h2> How does it work </h2> </summary>
    <details>
    <summary><h3>Finding conda instalation </h3></summary>
      
  To find the conda installation the script uses a function that goes through a series of if statements going through the most common Anaconda and Anaconda based env managers intall directories.

  ```bash
    
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

```
  If this fails it request the conda install directory directly.
  ```bash
    
  elif command -v conda >/dev/null 2>&1; then
    CONDA_BASE=$(conda info --base 2>/dev/null)
    if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
      echo "Found conda at: $CONDA_BASE/etc/profile.d/conda.sh"
      . "$CONDA_BASE/etc/profile.d/conda.sh"
      return 0
    fi
  fi

  ```
  
  </details>
 <details >
  <summary><h3>Environment activation and location variables</h3></summary>
  
  The script first activates emu environment unfortunately theres no way to automatically look through conda envs to find one with emu and its dependencies installed so we had to settle for a predefined env.
  
  If you have another env with Emu installed you can change the env in this line inside the script to the one with Emu installed

  ```bash
    
  # Activate your environment
  conda activate emu
```

  Additionally the script knows its location and it bases the working directory locations relative to it. And it moves to the raw data directory before starting to process the data.

  ```bash
    
  LOCATION="$(cd -- "$(dirname -- "$0")" && pwd)"
  EMU_DATABASE_DIR=$LOCATION/database
  EMU_DEFAULT_RESULTS=$LOCATION/results
  RAW_DATA=$LOCATION/raw_data

  cd $RAW_DATA

```
  </details>
 <details>
  <summary><h3>Data processing</h3></summary>
    
  The script uses a for loop to process data given.

  ```bash
    
  for i in *fastq; do
    emu abundance --db $EMU_DATABASE_DIR $i --keep-counts --output-dir $EMU_DEFAULT_RESULTS --threads 3
  done

  wait
```
  
  Afterwards it combines the results and splits the tables in the different files required for further analysis.

  ```bash
    
  emu combine-outputs --split-tables "${EMU_DEFAULT_RESULTS}" species
  emu combine-outputs --counts --split-tables "${EMU_DEFAULT_RESULTS}" species
  echo done
```
  
  You can change the taxonomic level at which the tables are combined by changing the argument species for another taxonomic level or preferably add more combine-output commands that combine the results at other taxonomic levels. As the biome pipeline is design to work at species level.
  
  More information can be found in the [Emu github repository](https://github.com/treangenlab/emu).
  </details>
</details>
