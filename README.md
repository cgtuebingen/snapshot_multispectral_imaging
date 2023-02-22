# A computational camera with programmable optics for snapshot high-resolution multispectral imaging

We present a snapshot multispectral imaging technique with a computational camera and a corresponding image restoration algorithm. The main characteristics are:
(1) transferring spectral information to the spatial domain by engineering user-defined PSFs; (2) measuring spectral images by computationally inverting the image formation. The design of our computational camera is based on a phase-coded aperture technique to generate spatial and spectral variant PSFs. The corresponding algorithm is designed by adapting single-channel and cross-channel priors. We show experimentally the viability of our technique: it reconstructs high-resolution multispectral images from a snapshot. We further validate that the role of PSF design is critical.

This repository contains the reconstruction MATLAB code from the encoded image to the spectral images. 

<img src="https://user-images.githubusercontent.com/7547278/220628159-9714576a-2907-454a-91e5-536fd6e277ab.png" width="500"> <img src="https://user-images.githubusercontent.com/7547278/220628543-14f17c15-ae93-4abf-b630-f2e99299c2ce.png" width="100"> <img src="https://user-images.githubusercontent.com/7547278/220628826-728d9194-0a37-4259-a65f-29a4e7c61661.png" width="300"> 
<p align="center">
<img src="https://user-images.githubusercontent.com/7547278/220629707-56a7f8df-df36-4e66-b13f-46cddd9df038.png" width="300">
</p>

### [Paper](https://link.springer.com/chapter/10.1007/978-3-030-20893-6_43)

## Citation

```
@inproceedings{chen2019computational,
  title={A computational camera with programmable optics for snapshot high-resolution multispectral imaging},
  author={Chen, Jieen and Hirsch, Michael and Eberhardt, Bernhard and Lensch, Hendrik PA},
  booktitle={Computer Vision--ACCV 2018: 14th Asian Conference on Computer Vision, Perth, Australia, December 2--6, 2018, Revised Selected Papers, Part III 14},
  pages={685--699},
  year={2019},
  organization={Springer}
}
```
