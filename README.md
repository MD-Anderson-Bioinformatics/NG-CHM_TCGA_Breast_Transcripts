# Create NG-CHM

This repository contains a script to collect the data for and construct this NG-CHM: [https://tcga.ngchm.net/NGCHM/chm.html?map=48a854d220343348b732e30061aa9a00d2e2ba28](https://tcga.ngchm.net/NGCHM/chm.html?map=48a854d220343348b732e30061aa9a00d2e2ba28).

To collect data:

```bash
./get_data.sh
```

To create an NG-CHM from this data and export it to an HTML file:

```bash
Rscript -e "source('create-ngchm.R')"
```


