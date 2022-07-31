-- Cleaning Data in SQL Queries
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
	  FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date;

UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(Date,SaleDate)
	
--------------------------------------------------------------------------------
-- Populate Property Address Data
SELECT *
	FROM [Portfolio Project]..NashvilleHousing
	--WHERE PropertyAddress is NULL
	ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
	FROM [Portfolio Project]..NashvilleHousing a
	JOIN [Portfolio Project]..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
	WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,  b.PropertyAddress)
	FROM [Portfolio Project]..NashvilleHousing a
	JOIN [Portfolio Project]..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
	WHERE a.PropertyAddress is null
--------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Addresss, City, State)

SELECT PropertyAddress
	FROM [Portfolio Project]..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))AS Address
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress nvarchar(250)
UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 
ALTER TABLE NashvilleHousing
	ADD PropertySplitCity  nvarchar(250)
UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
	FROM [Portfolio Project]..NashvilleHousing



SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project]..NashvilleHousing


SELECT *
	FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress nvarchar(250)
UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity  nvarchar(250)
UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState  nvarchar(250)
UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
	FROM [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
	FROM [Portfolio Project]..NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
	FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
	FROM [Portfolio Project]..NashvilleHousing


--------------------------------------------------------------------------------

-- Remove Duplicates 

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
			) AS row_num
	FROM [Portfolio Project]..NashvilleHousing
		--ORDER BY ParcelID
)


Select *
	FROM RowNumCTE
	WHERE row_num > 1
	--ORDER BY PropertyAddress

--------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
	FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NashvilleHousing
	DROP COLUMN SaleDate