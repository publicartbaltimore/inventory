(self.webpackChunkrdeck=self.webpackChunkrdeck||[]).push([[844],{1787:(r,e,t)=>{var o=t(2582),n=t(4102),a=t(1540),i=t(9705).default,l=a.featureEach,u=(a.coordEach,n.polygon,n.featureCollection);function c(r){var e=new o(r);return e.insert=function(r){if("Feature"!==r.type)throw new Error("invalid feature");return r.bbox=r.bbox?r.bbox:i(r),o.prototype.insert.call(this,r)},e.load=function(r){var e=[];return Array.isArray(r)?r.forEach((function(r){if("Feature"!==r.type)throw new Error("invalid features");r.bbox=r.bbox?r.bbox:i(r),e.push(r)})):l(r,(function(r){if("Feature"!==r.type)throw new Error("invalid features");r.bbox=r.bbox?r.bbox:i(r),e.push(r)})),o.prototype.load.call(this,e)},e.remove=function(r,e){if("Feature"!==r.type)throw new Error("invalid feature");return r.bbox=r.bbox?r.bbox:i(r),o.prototype.remove.call(this,r,e)},e.clear=function(){return o.prototype.clear.call(this)},e.search=function(r){var e=o.prototype.search.call(this,this.toBBox(r));return u(e)},e.collides=function(r){return o.prototype.collides.call(this,this.toBBox(r))},e.all=function(){var r=o.prototype.all.call(this);return u(r)},e.toJSON=function(){return o.prototype.toJSON.call(this)},e.fromJSON=function(r){return o.prototype.fromJSON.call(this,r)},e.toBBox=function(r){var e;if(r.bbox)e=r.bbox;else if(Array.isArray(r)&&4===r.length)e=r;else if(Array.isArray(r)&&6===r.length)e=[r[0],r[1],r[3],r[4]];else if("Feature"===r.type)e=i(r);else{if("FeatureCollection"!==r.type)throw new Error("invalid geojson");e=i(r)}return{minX:e[0],minY:e[1],maxX:e[2],maxY:e[3]}},e}r.exports=c,r.exports.default=c}}]);