/*
Cleaning Data in SQL Query
*/


Select *
From PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, ISNULL(N1.PropertyAddress,N2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing N1
Join PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	and N1.[UniqueID ] <> N2.[UniqueID ]
Where N1.PropertyAddress is null

Update N1 
Set PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing N1
Join PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	and N1.[UniqueID ] <> N2.[UniqueID ]
Where N1.PropertyAddress is null

Select *
From NashvilleHousing
------------------------------------------------------------------------

--Break Address down into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add SplicedAddress nvarchar(255);

Update NashvilleHousing
Set SplicedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add SplicedCity nvarchar(255);

Update NashvilleHousing
Set SplicedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress 
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplicedAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplicedAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplicedCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplicedCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplicedState nvarchar(255);

Update NashvilleHousing
Set OwnerSplicedState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------

--Change character Y and N in "Sold As Vacant" field to 'Yes' and 'No'


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
------------------------------------------------------------------------

--Remove duplicates

With #RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
From #RowNumCTE
where row_num > 1


Select *
From PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------

--Delete unused columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate

