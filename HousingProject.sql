 Select *
 From PortfolioProject..NashvilleHousing

 --**************************************************************************

 --Standardize the Date Format

 Select SaleDate, Convert(Date,SaleDate)
 From PortfolioProject..NashvilleHousing
 
 Update NashvilleHousing
 SET SaleDate = CONVERT(Date, SaleDate)
 
--The above script directly rewrites the date column with the converted format of date 
--But if you want to keep the original column as it is and add another column 
--and populte it with converted format then the below code needs to be executed 

 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;
 --Adds up a column

 Update NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)
 --Updates the newly added column with edited dates

 --****************************************************************************

 --"Populate Null Property Address Data"

 Select *
 From PortfolioProject..NashvilleHousing
 Where PropertyAddress is NULL
 --Found that there are few line items where the Property Address is null

 Select *
 From PortfolioProject..NashvilleHousing
 Order By ParcelID
 --This helped us undestand that wherever the parcel id's are equal there the property adresses are also the same. 
 --So we will be using this logic to populate the null property addresses


 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject..NashvilleHousing a
 Join PortfolioProject..NashvilleHousing b
	ON a.parcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
 WHERE a.PropertyAddress is NULL
 --By joining the table to itself on a condition of same parcel ids but different unique ids, 
 -- we found the address that needs to be populated in the null addresses
 --The last column generated from ISNULL is the column that needs to be populated in "a.PropertyAddress"


 Update a
 SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject..NashvilleHousing a
 Join PortfolioProject..NashvilleHousing b
	ON a.parcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
 WHERE a.PropertyAddress is NULL

 
 --****************************************************************************


--"Breaking out address into individual columns"

 Select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address, 
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
 From PortfolioProject..NashvilleHousing
 -- Divided the entire address into address and city


 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255);
 --adds up two columns

 Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)
 
 Update NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))
 --updates the newly added cloumn with edited address

--****************************************************************************

 --"Splitting owners address into address, city and state"

 Select
 PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)
 From PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(255);
 --adds up two columns

 Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)
 
 Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OWNERADDRESS,',','.'),2)

 Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)
 --updates the newly added cloumn with edited address

--****************************************************************************

 --"Change Y and N to Yes and No in Sold as Vacant Field"

 Update NashvilleHousing
 SET SoldAsVacant = REPLACE(SoldAsVacant,'N','No')
 From PortfolioProject..NashvilleHousing
 --There are two ways of doing this the above method of parsing poses a slight challnege as it just checks for particular character 
 --to find and replace and not the complete word, So when you give command to replace all the Y to Yes then all the Y will definetely 
 --become Yes but also the Yes which exist already will become Yeses. So to avoid this what you can do is Convert all the Yes to Y  
 --and all the No to N first
 --Now you can again convert all the Y to Yes and all N to No

 --This is one way of doing this the other is using case statement as below
 

 Select  Distinct(SoldAsVacant), COUNT(SoldAsVacant)
 From PortfolioProject.dbo.NashvilleHousing
 Group By SoldAsVacant
 Order By 2



 Select SoldAsVacant, 
 CASE When SoldAsVacant='Y' THEN 'Yes'
	  When SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
 From PortfolioProject.dbo.NashvilleHousing
 



 Update NashvilleHousing
 SET SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'Yes'
	  When SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
-- Here we tried updating the column SoldasVacant without creating a new column and updating that
-- Where as everywhere else we created a new column and then updated it

---------------------------------------------------------------------------------------------------------------------------
