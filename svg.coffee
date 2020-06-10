class Chart
	xmlns = 'http://www.w3.org/2000/svg'
	boxWidth = 800 							#ширина поля изображения
	boxHeight = 500 						#выста поля изображения
	maxX = 1000 							#максимальное значение по X
	maxY = 100								#макисмальное значение по Y
	marginR = 20							#отступ справа
	marginL = 30							#отступ слева
	marginT = 20							#отступ сверху
	marginB = 20							#отступ снизу
	startX = marginL						#координата нулевого значения по X
	endX = boxWidth - marginL - marginR		#координата последнего значения по X
	startY = boxHeight - marginB			#координата нулевого значения по Y
	endY = marginT							#координата последнего значения по Y
	gridWidth = endX - startX				#ширина поля диаграммы
	gridHeight = startY - endY				#высота поля диаграммы
	gridStepX = 100							#шаг сетки по X
	gridStepY = 20							#шаг сетки по Y

	#Перевод значений по X в координаты
	valX : (val) ->
		marginL + gridWidth / maxX * val

	#Перевод значений по Y в координаты
	valY : (val) ->
		marginT + gridHeight - (gridHeight / maxY * val)

	#Генератор ломанной
	#arrCoord - массив координат [[x0,y0],[x1,y1],[x2,y2],..,[xN,yN]]
	#style - стиль объекта
	#id - идентификатор
	getPolyline : (arrCoord,style="",className="",id="") ->
		p = document.createElementNS xmlns, "polyline"
		p.className.baseVal.value = className
		p.id = id
		p.style.cssText = "fill:none;"+style
		points = ""
		for i in arrCoord
			points = points + " "+ i[0] + "," + i[1]
		p.setAttributeNS null, "points", points
		p
		
	#Генератор линии
	#x1,y1 - координаты начала линии
	#x2,y2 - координаты конца линии
	#style - стиль линии
	getLine : (x1,y1,x2,y2,style="",id="") ->
		l = document.createElementNS xmlns, "line"
		l.y1.baseVal.value = y1
		l.y2.baseVal.value = y2
		l.x1.baseVal.value = x1
		l.x2.baseVal.value = x2
		l.style.cssText = style
		l.id = id
		l

	#Генератор квадрата
	#x,y координаты левого верхнего угла
	#width ширина
	#height высота 
	#rx,ry радиусы скругления
	#className имя класса
	#style объект стилей
	#id идентификатор
	getRect : (x = 0, y = 0, width = 0, height = 0, rx = 0, ry = 0, style = '', className = '', id = '') ->
		r = document.createElementNS xmlns, "rect"
		r.className.baseVal.value = className
		r.x.baseVal.value = x
		r.y.baseVal.value = y
		r.rx.baseVal.value = rx
		r.ry.baseVal.value = ry
		r.width.baseVal.value = width
		r.height.baseVal.value = height
		r.style.cssText = style
		r.id = id
		r

	#Генератор текста
	#text - текст
	#x,y - координаты
	getText : (text="",x=0,y=0,style="",className="",id="") ->
		t = document.createElementNS xmlns, "text"
		t.className.baseVal.value = className
		t.style.cssText = style
		t.id = id
		t.setAttributeNS null, "x", x
		t.setAttributeNS null, "y", y
		t.innerHTML = text
		t


	#Нарисовать границу графика
	drawGridBorder : (svgElem) ->
		b = this.getRect marginL,marginT,gridWidth,gridHeight,0,0,"fill: none; stroke: black","gridBorder"
		svgElem.appendChild b
		b

	#Нарисовать сетку по X
	drawGridX : (svgElem) ->
		g = document.createElementNS xmlns, "g"
		g.className.baseVal = "grid gridX"
		svgElem.appendChild g
		i = 0
		while i < maxX / gridStepX
			l = this.getLine this.valX(i * gridStepX),startY,this.valX(i * gridStepX),endY
			g.appendChild l
			i++
		g

	#Нарисовать сетку по Y
	drawGridY : (svgElem) ->
		g = document.createElementNS xmlns, "g"
		g.className.baseVal = "grid gridY"
		svgElem.appendChild g
		i = 0
		while i < maxY / gridStepY
			l = this.getLine startX,this.valY(i * gridStepY),endX,this.valY(i * gridStepY)
			g.appendChild l
			i++
		g

	setLabelX : (svgElem) ->
		g = document.createElementNS xmlns, "g"
		g.className.baseVal = "label labelX"
		svgElem.appendChild g
		i = 0
		while i < maxX / gridStepX
			x = this.valX(i*gridStepX)
			y = startY
			t = this.getText i*gridStepX,x,y,"color:black"
			g.appendChild t
			box = t.getBBox()
			boxX = box.x
			boxY = box.y
			boxW = box.width
			boxH = box.height
			t.setAttributeNS null, "y", y+boxH
			t.setAttributeNS null, "x", x-boxW/2
			i++
		g


	setLabelY : (svgElem) ->
		g = document.createElementNS xmlns, "g"
		g.className.baseVal = "label labelY"
		svgElem.appendChild g
		i = 0
		while i < maxY / gridStepY
			x = startX
			y = this.valY(i * gridStepY)
			t = this.getText i*gridStepY,x,y,"color:black"
			g.appendChild t
			box = t.getBBox()
			boxX = box.x
			boxY = box.y
			boxW = box.width
			boxH = box.height
			t.setAttributeNS null, "y", y+boxH/3
			t.setAttributeNS null, "x", x-boxW
			i++
		g


	addGraph : (svgElem,arr=[],color) ->
		arrCoord = []
		for i in arr
			arrCoord.push [this.valX(i[0]), this.valY(i[1])]
		p = getPolyline arrCoord,"stroke:"+color
		svgElem.appendChild p
		p


	#Нарисовать график
	constructor: (@container) ->
		svg = document.createElementNS xmlns, 'svg'
		svg.setAttributeNS null, 'viewBox', '0 0 ' + boxWidth + ' ' + boxHeight
		svg.setAttributeNS null, 'width', boxWidth
		svg.setAttributeNS null, 'height', boxHeight
		svg.style.display = 'block'
		cont = document.getElementById(@container)
		cont.appendChild svg
		this.drawGridX svg
		this.drawGridY svg
		this.drawGridBorder svg
		this.setLabelX svg
		this.setLabelY svg
		svg

chart = new Chart 'svgContainer'
c1 = [1,20]
c2 = [110,60]
c3 = [200,50]
arr = [c1,c2,c3]
#addGraph chart,arr,"red" 