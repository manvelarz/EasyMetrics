macroScript DistanceMarcker
category:"Manvel"
tooltip:"Distace"
buttontext:"DM"
		

(
on execute do

(
	Global IniPath = (getDir #temp + "\\DistanceMetricConfig.ini")
try(closeRolloutFloater rof) catch()
Global rof=newrolloutfloater "Distance Metrics" 200 400 800 200
global pt1
global pt2
global TextSize = 100
global TextSizeCoef = 3
global ExtAmount = 0.1
global lineheight = 25
global decimals = 1
global dist = 1
global boxWidth = 0.3
Global textDist= 10
	--  Q
fn WrightToINI TemplName = (
	
	)
fn coordplane mytrans =(
plane name:"coord_plane" length:10 width:10 lengthsegs:1 widthsegs:1 transform:mytrans
$coord_plane.renderable = off
--freeze $coord_plane
--hide $coord_plane
)
fn round RawDist decimals = (
	num = dotNetObject "System.Double" RawDist 
	roundedDist = ((dotNetClass "System.Math").round num decimals) as float
	)
fn DistText myTrans= (
	t = text wirecolor:(color 0 0 0) position:((pt1+pt2)/2) text:(round dist decimals as string) size:(dist/TextSizeCoef) transform:myTrans
	--t.dir  = p1 - p2
	in coordsys local  t.pos.y += textDist
	addModifier t (extrude amount:ExtAmount)
	)
fn localMatrix p1 p2 p3 p4 = (
  		v1 = normalize (p2 - p1)
		v3 = normalize (cross v1 (normalize (p3 - p1)))
		v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 p4
) 

fn Liness = (
	line1 = box wirecolor:(color 0 0 0)  length:boxWidth width:boxWidth height:lineheight transform:myBox1matrix
	line1.rotation.x_rotation -= 90
	line2 = box wirecolor:(color 0 0 0)  length:boxWidth width:boxWidth height:lineheight  transform:myBox2matrix
	line2.rotation.x_rotation -= 90
)	

	
--dist = distance (p1 = pickPoint snap:#3D) (p2 = pickPoint snap:#3D rubberBand:p1)
--zdir = normalize(cross p1 p2)
rollout Templates "Templates" --width:290 height:328
(
	edittext Sel_Template text:"selTemplate"
	listBox TemplateList items:#("Item 1","Item 2")
button addToList "Add Item To End Of List" width:180 enabled:false
button insertToList "Insert After Current Item" width:180
button removeFromList "Remove Current Item" width:180
--Append a new Item to the array. Since append returns the resuling array,
--it is OK to assign the result directly to the .items property
on TemplateList selected sel do (
	 Sel_Template.text = TemplateList.items[sel]
	)
on TemplateList doubleClicked sel do (
	 Sel_Template.text = TemplateList.items[sel]
	)
on addToList pressed do(
	if appendIfUnique TemplateList.items Sel_Template.text then (
		TemplateList.items = append TemplateList.items Sel_Template.text
		)
	else(
		if queryBox "You have template with name ...\n Are you sure you whant to replace?" beep:true then messagebox "todo replace property"
		)
	)
  
--Instert new item before current item
on insertToList pressed do
	(
	  --Check whether current item selection exists (greater than 0)
	  if TemplateList.selection > 0 do
	  (
		--Because insertItem returns OK instead of the resulting array,
		--you cannot assign the result of the expression directly to the property.
		--Instead, you have to get a copy of the items array in a local variable...
		temp_array = TemplateList.items
		--...perform the insertion with the temp. array in the local variable...
		insertItem Sel_Template.text temp_array TemplateList.selection
		--...and assign back the temp. array to the .items property
		TemplateList.items = temp_array
	  )
	)

on removeFromList pressed do --Remove currently selected item from the list:
	(
	  --Check whether there are any items left and there is a valid selection.
	  --Then delete the current item. DeleteItem returns the resulting array,
	  --so you can assign the result directly to the .items property
	  if TemplateList.items.count > 0 and TemplateList.selection > 0 do
		TemplateList.items = deleteItem TemplateList.items TemplateList.selection
	)
on Sel_Template changed mytext do addToList.enabled = true
)
rollout default "Default params" --width:290 height:328
(
	Group "Text" (
	spinner 'TextSize' "Size" 
	spinner 'TextOffset' "Offset" 	
	spinner 'RoundDecimals' "Round Decimals" 	type:#integer		--pos:[28,49]width:43 height:16 enabled:true 
	spinner 'ExtrudeAmount' "Extrude" 		
	)
	Group "Lines" (
	spinner 'heigth' "Heigth" 
	spinner 'width' "Width" 		--pos:[28,49]width:43 height:16 enabled:true 
	)
)
addrollout Templates  rof
addrollout default  rof
	
snapMode.Active = True

	
global pt1 = pickpoint snap:#3d
	if classof pt1 == point3 then
	(
		print pt1
		global pt2 = pickpoint snap:#3d rubberband:pt1
			if classof pt2 == point3 then
			(
				format "pt2 --> %\n"  pt2
				format "pt1-pt2= %\n" (pt1-pt2)
				format "norm pt1-pt2= %\n" (normalize(pt1-pt2))
				pt3 = [(pt2.x),(pt2.y+10),(pt2.z)]
				dist = distance pt1 pt2
				myTextmatrix = localMatrix pt1 pt2 pt3 ((pt1+pt2)/2)
				Global myBox1matrix = localMatrix pt1 pt2 pt3 pt1
				Global myBox2matrix = localMatrix pt1 pt2 pt3 pt2
				coordplane myBox1matrix
				DistText myTextmatrix
				
				print pt1+pt2
				Liness()
				--try $coord_plane.parent = $ catch()
			)
	)




) -- execute
) -- macr