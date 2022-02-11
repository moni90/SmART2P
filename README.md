SmART2P
========
A software for the generation and processing of Smart and Accurate Recording Trajectories for population two-photon calcium imaging

The code allows to import and process two-photon calcium imaging raster acquisitions, design smart line scanning (SLS) trajectories for faster and more accurate data acquisition and process two-photon calcium imaging SLS acquisitions.

# Usage and documentation

A full description of the software can be found in SmART2P_guide.pdf

# Citation

If you use this code please cite the corresponding papers where original methods appeared (see References below), as well as: 

<a name="SmART2P"></a>[1] Moroni M., Brondi M., Fellin T., Panzeri S. (2022). SmART2P: a software for the generation and processing of Smart and Accurate Recording Trajectories for population two-photon calcium imaging. [[paper]](https://doi.org/)


# References

The following references provide the theoretical background and original code for the included methods. 

### Segmentation, deconvolution and demixing of calcium imaging data

<a name="caiman"></a>[1] Giovannucci A., Friedrich J., Gunn P., Kalfon J., Brown B.L., Koay S.A., Taxidis J., Najafi F., Gauthier J.L., Zhou P., Khakh B.S., Tank D.W., Chklovskii D.B., Pnevmatikakis E.A. (2019). CaImAn: An open source tool for scalable Calcium Imaging data Analysis. eLife. [[paper]](https://doi.org/10.7554/eLife.38173)

<a name="neuron"></a>[2] Pnevmatikakis, E.A., Soudry, D., Gao, Y., Machado, T., Merel, J., ... & Paninski, L. (2016). Simultaneous denoising, deconvolution, and demixing of calcium imaging data. Neuron 89(2):285-299, [[paper]](http://dx.doi.org/10.1016/j.neuron.2015.11.037). 

<a name="struct"></a>[3] Pnevmatikakis, E.A., Gao, Y., Soudry, D., Pfau, D., Lacefield, C., ... & Paninski, L. (2014). A structured matrix factorization framework for large scale calcium imaging data analysis. arXiv preprint arXiv:1409.2903. [[paper]](http://arxiv.org/abs/1409.2903). 

<a name="oasis"></a>[4] Friedrich J. and Paninski L. Fast active set methods for online spike inference from calcium imaging. NIPS, 29:1984-1992, 2016. [[paper]](https://papers.nips.cc/paper/6505-fast-active-set-methods-for-online-spike-inference-from-calcium-imaging), [[Github repository - Python]](https://github.com/j-friedrich/OASIS), [[Github repository - MATLAB]](https://github.com/zhoupc/OASIS_matlab).

<a name="mcmc"></a>[5] Pnevmatikakis, E. A., Merel, J., Pakman, A., & Paninski, L. Bayesian spike inference from calcium imaging data. In Signals, Systems and Computers, 2013 Asilomar Conference on (pp. 349-353). IEEE, 2013. [[paper]](https://arxiv.org/abs/1311.6864), [[Github repository - MATLAB]](https://github.com/epnev/continuous_time_ca_sampler).

### Motion Correction

<a name="normcorre"></a>[6] Pnevmatikakis, E.A., and Giovannucci A. (2017). NoRMCorre: An online algorithm for piecewise rigid motion correction of calcium imaging data. Journal of Neuroscience Methods, 291:83-92 [[paper]](https://doi.org/10.1016/j.jneumeth.2017.07.031), [[Github repository - MATLAB]](https://github.com/simonsfoundation/normcorre).


Dependencies
========

The CVX library which can be downloaded from http://cvxr.com/cvx/download/ (after unpacking CVX open Matlab and run cvx_setup from inside the CVX directory to properly install and add CVX to the Matlab path).
