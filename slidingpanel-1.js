
 /**
  *	SlidingPanel 1.1
  *	------------------------------------------------------------------------
  *	Crossbrowser, fully customizable JavaScript/DHTML Script to open/close a
  *	panel with a sliding visual effect, with optional fading effect.
  *
  *	Copyright (C) 2004-2005 Claudio Procida
  *	cla@emeraldion.it
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License as published by
  *	the Free  Software Foundation;  either version 2  of the License, or
  *	(at your option) any later version.
  *
  *	This program is distributed in the hope that it will be useful,
  *	but WITHOUT ANY WARRANTY;  without even the implied warranty of
  *	MERCHANTABILITY  or FITNESS  FOR A PARTICULAR PURPOSE.  See the
  *	GNU General Public License for more details.
  *
  *	You should have received a copy of the GNU General Public License
  *	along with this program; if not, write to the Free Software
  *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  *
  *
  *	Usage
  *
  *	var myPanel = new SlidingPanel('panelID');
  *	myPanel.setIcon('buttonID', 'image/when/open.gif', 'image/when/closed.gif');
  *	myPanel.setLabel('labelID', 'text when open', 'text when closed');
  * myPanel.setSlideDuration(500); // in milliseconds
  * myPanel.setFade(true);
  *	myPanel.slide();
  *
  */
  
var slidingPanels = new Array();

function SlidingPanel(panelID)
{
	this.panel = sp_getObj(panelID);
	if (!this.panel)
		return;
	this.id = slidingPanels.length;

	if (uA.IE) { // hack to init IE's filter rendering engine
		var dummy = document.createElement('div');
		dummy.style.position = 'absolute';
		dummy.style.top = 0;
		dummy.style.left = 0;
		dummy.style.width = '1px';
		dummy.style.height = '1px';
		dummy.style.filter = 'alpha(opacity=50)';
		this.panel.appendChild(dummy);
	}

	this.icon = null;
	this.label = null;
	this.duration = 500;
	this.fade = true;
	this.restHeight = this.panel.style.height ? this.panel.style.height : 'auto';
	this.open = !(sp_getStyle(this.panel).display == 'none');
	this.animation = {now:(this.open ? 1.0 : 0.0), from:0.0, to:0.0, duration:0};
	if (this.open)
		this.height = this.panel.offsetHeight;
	else { // workaround to get panel height when hidden
		this.panel.style.display = 'block';
		this.height = this.panel.offsetHeight;
		this.panel.style.display = 'none';
	}

	this.slide = function() {
		if (this.open) {
			this.height = this.panel.offsetHeight;
			if (this.animation.timer != null) {
				clearInterval(this.animation.timer);
				this.animation.timer = null;
			}

			var starttime = (new Date).getTime() - 13;

			this.animation.duration = this.duration;
			this.animation.starttime = starttime;
			this.animation.timer = setInterval ("sp_slide('" + this.id + "')", 13);
			this.animation.from = this.animation.now;
			this.animation.to = 0.0;
			sp_slide(this.id);
		}
		else { // workaround to get panel height when hidden
			this.panel.style.display = 'block';
			this.panel.style.height = this.restHeight;
			this.height = this.panel.offsetHeight;
			this.panel.style.height = '1px';
			this.panel.style.display = 'none';
			
			if (this.animation.timer != null) {
				clearInterval (this.animation.timer);
				this.animation.timer  = null;
			}
	 
			var starttime = (new Date).getTime() - 13;
	 
			this.animation.duration = this.duration;
			this.animation.starttime = starttime;
			this.animation.timer = setInterval ("sp_slide('" + this.id + "')", 13);
			this.animation.from = this.animation.now;
			this.animation.to = 1.0;
			sp_slide(this.id);
		}
		this.open = !this.open;
	};
	
	this.setSlideDuration = function(duration) {
		this.duration = duration;
	};
	
	this.setLabel = function(labelID, textWhenOpen, textWhenClosed) {
		var label = sp_getObj(labelID);
		if (!label)
			return;
		this.label = {label:label, textWhenOpen:textWhenOpen, textWhenClosed:textWhenClosed};
	};

	this.setIcon = function(iconID, iconWhenOpen, iconWhenClosed) {
		var icon = sp_getObj(iconID);
		if (!icon)
			return;
		this.icon = {icon:icon, iconWhenOpen:iconWhenOpen, iconWhenClosed:iconWhenClosed};
	};

	this.setFade = function(fade) {
		this.fade = fade;
	};

	slidingPanels[this.id] = this;
	return this;
}

function sp_slide(id) { // visualizes a scrolling animation
	var T,
		ease,
		time = (new Date).getTime(),
		newHeight;

	T = sp_clampTo(time-slidingPanels[id].animation.starttime, 0, slidingPanels[id].animation.duration);
	if (T >= slidingPanels[id].animation.duration) {
		clearInterval (slidingPanels[id].animation.timer);
		slidingPanels[id].animation.timer = null;
		slidingPanels[id].animation.now = slidingPanels[id].animation.to;
		
		if (slidingPanels[id].label) {
			slidingPanels[id].label.label.innerHTML = slidingPanels[id].animation.now ? slidingPanels[id].label.textWhenOpen : slidingPanels[id].label.textWhenClosed;
		}
		if (slidingPanels[id].icon) {
			slidingPanels[id].icon.icon.src = slidingPanels[id].animation.now ? slidingPanels[id].icon.iconWhenOpen : slidingPanels[id].icon.iconWhenClosed;
		}
	}
	else {
		ease = 0.5 - (0.5 * Math.cos(Math.PI * T / slidingPanels[id].animation.duration));
		slidingPanels[id].animation.now = sp_computeNextFloat (slidingPanels[id].animation.from, slidingPanels[id].animation.to, ease);
	}
	
	var sPstyle = slidingPanels[id].panel.style;
	sPstyle.display = slidingPanels[id].animation.now ? 'block' : 'none';
	sPstyle.overflow = 'hidden';
	if (slidingPanels[id].fade) {
		if (uA.IE)
			sPstyle.filter = 'alpha(opacity=' + Math.round(slidingPanels[id].animation.now*100) + ')';
		else if (uA.Gecko)
			sPstyle.MozOpacity = slidingPanels[id].animation.now < 1 ? slidingPanels[id].animation.now : 0.99; // to avoid flickering
		else if (uA.Safari)
			sPstyle.opacity = slidingPanels[id].animation.now;
	}
	newHeight = Math.round(slidingPanels[id].animation.now*slidingPanels[id].height);
	sPstyle.height = (uA.IE ? sp_clampTo(newHeight, 1, newHeight) : newHeight) + 'px'; // IE dislikes a height of 0
	if (slidingPanels[id].animation.now == 1.0) {
		sPstyle.height = slidingPanels[id].restHeight;
	}
}

function sp_getStyle(obj)
{
	if ('getComputedStyle' in window && !uA.Safari)
		return getComputedStyle(obj, '');
	else if (document.body.currentStyle)
		return obj.currentStyle;
	else
		return obj.style;
}

function sp_getObj(id)
{
	return (document.getElementById ? document.getElementById(id) : document.all[id]);
}

function sp_clampTo(value, min, max) { // constrains a value between two limits
	return value < min ? min : value > max ? max : value;
}

function sp_computeNextFloat (from, to, ease) { // self explaining
	return from + (to - from) * ease;
}

uA = new Object();
uA.IE = navigator.appName.indexOf('Microsoft') != -1;
uA.Gecko = navigator.userAgent.indexOf('Gecko') != -1 && navigator.userAgent.indexOf('Safari') == -1;
uA.Safari = navigator.userAgent.indexOf('Safari') != -1;
