<p align="center">
<img src="resources/header.png"/>
</p>

________________________________________________________________________________________________________________________________________
## Latest downloads

- [MATLAB App installer v17.08 (recommended)](https://github.com/abarletta/rndfittool/releases/download/v17.08/RND.Fitting.Tool.v17.08.mlappinstall)
- [Zip archive containing all codes v17.08](https://github.com/abarletta/rndfittool/releases/download/v17.08/RND.Fitting.Tool.v17.08.zip)

<b>Changelog</b> <br>
- [2017-08-28] Added model-free computation of options sensitivity with respect to variance-swap (VS vega); Fixed compatibility issue occurring on Unix systems.
- [2017-06-26] Fixed a bug producing bad plotting in Matlab most recent versions (>R2015b).
- [2017-04-27] Fixed a bug occurring when plotting greeks.

________________________________________________________________________________________________________________________________________
## Getting Started

The _Risk-neutral Density Fitting Tool_ tool (rndfittool) allows the user to infer the risk-neutral density (RND), the risk-neutral moments and the greeks embedded in a set of observed call and put option prices. The underlying  methodology is fully non-structural, meaning that it does not rely on any parametric model, and it consists in approximating the RND through orthogonal polynomial expansions. A detailed description of this methodology is provided in <a href="https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2943964">this paper</a>.
Please note that this tool is <b>not a standalone software</b>, but it fully relies on the MATLAB suite.

### Prerequisites

This code has been thoroughly tested on MATLAB R2015b and partially on versions R2016b, R2014a and R2014b. However, it is very likely that it also runs on other versions of MATLAB. The following MATLAB Toolboxes are required to ensure full compatibility of the code: 

- Curve Fitting Toolbox
- Financial Toolbox
- Optimization Toolbox
- Statistics and Machine Learning Toolbox

### Installing rndfittool

There are two options to install the Risk-neutral Density Fitting Tool on your machine.

#### Installing rndfittool as MATLAB App (recommended)
- Download the [MATLAB App installer](https://github.com/abarletta/rndfittool/releases/download/v17.04/RND.Fitting.Tool.mlappinstall).
- Double-click on the file to start the installation process.
- If the double-click does not work you may alternatively open the file by dragging it into the MATLAB command window.
- After the installation is done the Risk-neutral Density Fitting Tool icon will be listed among your MATLAB Apps.
- If the installation does not work switch to the next method.

#### Installing rdnfittool through zip archive
- Download the [zip archive](https://github.com/abarletta/rndfittool/releases/download/v17.04/RND.Fitting.Tool.zip) containing all the necessary resources.
- Extract the archive contents into a local folder.
- Set the folder containing the extracted file as MATLAB current folder or, alternatively, add it to the MATLAB path list. 
- Type <code>rndfittool</code> to run the tool.

________________________________________________________________________________________________________________________________________
## Quick usage

- Load input data. Native formats from OptionMetrics and CBOE are supported (see next section).

<p align="center">
<img src="resources/import_data.PNG" width="600"/>
</p>

- Infer risk-neutral mean and variance through <code>Edit input data</code>. Press <code>Edit input data</code> to validate your changes. Change strike boundaries (you may need to repeat this step in case the fitting is not satisfactory). Press <code>Apply tool</code> and <code>Apply and Exit</code> to save all changes and return to the main window.

<p align="center">
<img src="resources/find_mean_and_variance.PNG" width="600"/>
</p>

- Choose order (e.g. 11), kernel (e.g. Gen. Weibull) and method (e.g. PCA, 99%, constrained).

<p align="center">
<img src="resources/run.PNG" width="600"/>
</p>

- Press <code>Find greeks</code> to compute the greeks (still without using a model).

<p align="center">
<img src="resources/greeks.PNG" width="600"/>
</p>

- All plots and results can be exported through <code>Export plots</code> and <code>Export results</code>.

<p align="center">
<img src="resources/export.PNG" width="300"/>
</p>

________________________________________________________________________________________________________________________________________
## Supported data sources

The standard format for input data is a MAT-file (see [this sample](https://github.com/abarletta/rndfittool/raw/master/sample_option_data.mat)) with the following structure 

```
Variable name: [Size Type]
            K: [Mx1 double]  -----
         call: [Mx1 double]       | Mandatory
          put: [Mx1 double]       |
            m: [2x1 double]  -----
      obsDate: [1x6 int]     -----
      expDate: [1x6 int]          |
       call_a: [Mx1 double]       | Optional
       call_b: [Mx1 double]       |
        put_a: [Mx1 double]       |
        put_b: [Mx1 double]  -----
```

#### Mandatory variables:

- <code>K</code> vector of strike values
- <code>call</code> vector of observed call prices
- <code>put</code> vector of observed put prices
- <code>m</code> vector containing guessed mean and variance (can be set to [])

#### Optional variables:

- <code>obsDate</code> observation date in numeric format 'yyyy mm dd'
- <code>expDate</code> expiry date in numeric format 'yyyy mm dd'
- <code>call_a</code> vector of call ask prices
- <code>call_b</code> vector of call bid prices
- <code>put_a</code> vector of put ask prices
- <code>put_b</code> vector of put bid prices

### External sources

Input data can also be loaded from external sources and optionally converted into compatible MAT-file forma through <code>Edit input data</code>. However, loading MAT-formatted data is normally faster.

#### OptionMetrics

The data must have .xls, .xlsx or .csv extension and be formatted with all options (e.g. date format) set to the default values provided in the OptionMetrics download page. The dataset must contain all the information related to the mandatory variables. Possibly unrequired fields can be safely appended at any position of the spreadsheet, if needed. Options with several maturities and/or observation dates can be collected into the same file. If this is the case, the user will be asked to choose a maturity when loading data.

[Visit OptionMetrics website](http://www.optionmetrics.com/)

#### CBOE

The data may be saved either into default .dat format available at CBOE website or be pre-converted into .xls/.xlsx format. The dataset must contain all the information related to the mandatory variables. Possibly unrequired fields can be safely appended at any position of the spreadsheet, if needed. If this is the case the user will be asked to choose a maturity when loading data.

[Visit CBOE website](http://www.cboe.com/delayedquote/quote-table)

________________________________________________________________________________________________________________________________________
## About the software

<b>Current version</b> <br>
17.06<br>
<b>Author</b> <br>
[Andrea Barletta](http://pure.au.dk/portal/en/persons/id(e161f76b-35b6-4903-b768-e8b172cbede5).html)<br>
<b>Acknowledgments</b> <br>
[Paolo Santucci de Magistris](https://sites.google.com/universitadipavia.it/paolosantuccidemagistris/home) provided great contribuition to the project.
