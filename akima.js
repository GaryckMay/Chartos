'use strict';
var x=new Array(1,5,10,15,20,25,30),
y=new Array(1,10,11,6,15,6,8),
n=new Array(1,2,3,4,5,6,7);
console.log(Akima(x,y,n));

function Akima(xa, ya, xYnterp)
{
	var xa100 = new Array();
	var ya100 = new Array();
	var xYnterp100 = new Array();
	var yYnterp = new Array();
	var n = xa.length;
	var xYnterpLength = xYnterp.length;
	var xstep = 1;
	for (var i=0; i<xa.length; i++)
	{
		xa100.push(parseInt(xa[i]*100000));
		ya100.push(parseFloat(ya[i]*100000));
	}
	for (var i=0; i<xYnterpLength; i++)
	{
		xYnterp100.push(parseInt(xYnterp[i]*100000));
	}
	for (var j = 0; j < xYnterpLength; j++)
	{
		yYnterp[j] = calcsplineAkima(xa100, ya100, n, xstep, xYnterp100[j], xYnterp100[j]);
	}
//document.write(yYnterp);
return yYnterp;
}

function calcsplineAkima(xa, ya, n, xstep, llimit, ulimit)
//перевод с PHP http://habrahabr.ru/post/130873/ Михаил Сартаков msartakov@gmail.com
	{
		var xAkima = new Array();
		var yAkima = new Array();
		for (var i=0; i<xa.length; i++)
		{
		xAkima.push(xa[i]);
		yAkima.push(ya[i]);
		}
		if (n == 2)
		{ 
			var dx = xAkima[1] - xAkima[0];
			var dy = yAkima[1] - yAkima[0];

			//$xstep = ($ulimit - $llimit) / $d;
			var d = Math.round((ulimit - llimit) / xstep);
			var m = dy / dx; 
			var r = new Array();
			for (i = 0; i <= d; i++)
			{
				r[xAkima[0] + i * xstep] = yAkima[0] + i * m * xstep;
			}
		}
		else
		{ 
		//alert(x);
			//x.unshift(x[0], x[1]);
			xAkima.unshift(xAkima[0], xAkima[1]);
			xAkima.push(0);
			xAkima.push(0);
			//$x[] = 0;
			//$x[] = 0;
			//y.unshift(y[0], y[1]);
			yAkima.unshift(yAkima[0], yAkima[1]);
			yAkima.push(0);
			yAkima.push(0);
			//$y[] = 0;
			//$y[] = 0;
			n+= 4;

			var dx = new Array();
			var dy = new Array();
			var m = new Array();
			var t = new Array();
			var C = new Array();
			var D = new Array();
			var r = new Array();
			
			for (var i = 2; i <= (n - 3); i++)
			{
				dx[i] = xAkima[i + 1] - xAkima[i];
				dy[i] = yAkima[i + 1] - yAkima[i];
				m[i] = dy[i] / dx[i]; 
			}

			xAkima[1] = xAkima[2] + xAkima[3] - xAkima[4];
			dx[1] = xAkima[2] - xAkima[1];
			yAkima[1] = dx[1] * (m[3] - 2 * m[2]) + yAkima[2];
			dy[1] = yAkima[2] - yAkima[1];
			m[1] = dy[1] / dx[1];
			xAkima[0] = 2 * xAkima[2] - xAkima[4];
			dx[0] = xAkima[1] - xAkima[0];
			yAkima[0] = dx[0] * (m[2] - 2 * m[1]) + yAkima[1];
			dy[0] = yAkima[1] - yAkima[0];
			m[0] = dy[0] / dx[0];
			xAkima[n - 2] = xAkima[n - 3] + xAkima[n - 4] - xAkima[n - 5];
			yAkima[n - 2] = (2 * m[n - 4] - m[n - 5]) * (xAkima[n - 2] - xAkima[n - 3]) + yAkima[n - 3];
			xAkima[n - 1] = 2 * xAkima[n - 3] - xAkima[n - 5];

			yAkima[n - 1] = (2 * m[n - 3] - m[n - 4]) * (xAkima[n - 1] - xAkima[n - 2]) + yAkima[n - 2];
			for (var i = n - 3; i < n - 1; i++)

			{
				dx[i] = xAkima[i + 1] - xAkima[i];
				dy[i] = yAkima[i + 1] - yAkima[i];
				m[i] = dy[i] / dx[i];
			}

			t[0] = 0.0;
			t[1] = 0.0; 
			for (var i = 2; i < n - 2; i++)
			{
				var num = Math.abs(m[i + 1] - m[i]) * m[i - 1] + Math.abs(m[i - 1] - m[i - 2]) * m[i];
				var den = Math.abs(m[i + 1] - m[i]) + Math.abs(m[i - 1] - m[i - 2]);
				if (den != 0) t[i] = num / den;
				else t[i] = 0.0;
			}

			for (var i = 2; i < n - 2; i++)
			{
				C[i] = (3 * m[i] - 2 * t[i] - t[i + 1]) / dx[i];
				D[i] = (t[i] + t[i + 1] - 2 * m[i]) / (dx[i] * dx[i]);
				//@C[i] = (3 * m[i] - 2 * t[i] - t[i + 1]) / dx[i];
				//@D[i] = (t[i] + t[i + 1] - 2 * m[i]) / (dx[i] * dx[i]);
			}

			var d = Math.round((ulimit - llimit) / xstep);
			var p = 2;

			for (var xv = llimit; xv < ulimit + xstep; xv+= xstep)
			{
				//while (xv >= x[p] && isset(x[p]))
				//while (xv >= x[p] && window.x[p] !== undefined)
				while (xv >= xAkima[p] && xAkima[p] !== undefined)
				{
					r[xAkima[p]] = yAkima[p];
					p++;
				}

				if (((xv - xAkima[p - 1]) > xstep / 100.0) && ((xAkima[p] - xv) > xstep / 100.0))
				{
					var xd = (xv - xAkima[p - 1]);
					r[xv] = yAkima[p - 1] + (t[p - 1] + (C[p - 1] + D[p - 1] * xd) * xd) * xd;
				}
			}
		}
			var last = r.pop();
			//xAkima.length = 0;
			//yAkima.length = 0;
			//dx.length = 0;
			//dy.length = 0;
			//m.length = 0;
			//t.length = 0;
			//C.length = 0;
			//D.length = 0;
			//r.length = 0;
		return last/100000;	
	}