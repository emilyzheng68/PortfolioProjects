# Cleaning Data in SQL Queries

SELECT * 
FROM nashville_housing.realestate;

# Standardize Date Format
ALTER TABLE realestate
ADD SaleDateConverted DATE;

SET SQL_SAFE_UPDATES = 0;
UPDATE realestate
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%e-%b-%y')
WHERE SaleDate IS NOT NULL;

Select SaleDateConverted
From nashville_housing.realestate;

# Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From nashville_housing.realestate;

SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS StreetAddress,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS CityAddress
FROM realestate;

ALTER TABLE realestate
Add PropertySplitAddress VARCHAR(255);

Update realestate
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE realestate
Add PropertySplitCity VARCHAR(255);

Update realestate
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

Select *
From nashville_housing.realestate;

Select OwnerAddress
From nashville_housing.realestate;

SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Street,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
  SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM realestate;

ALTER TABLE realestate
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255);

UPDATE realestate
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity    = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState   = SUBSTRING_INDEX(OwnerAddress, ',', -1);
    
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM realestate
LIMIT 66;

# Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant) 
FROM realestate;

SELECT SoldAsVacant,
       CASE 
         WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
       END AS SoldAsVacantNormalized
FROM realestate;

UPDATE realestate
SET SoldAsVacant = CASE 
                     WHEN SoldAsVacant = 'Y' THEN 'Yes'
                     WHEN SoldAsVacant = 'N' THEN 'No'
                     ELSE SoldAsVacant
                   END;
                   
# Examine Duplicates
WITH RowNumCTE AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
  FROM realestate
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

# Delete Unused Columns
ALTER TABLE realestate
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;






