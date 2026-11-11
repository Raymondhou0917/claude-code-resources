import{a as Oe,b as zt,c as wt,d as Gt,e as O,h as it,i as Xt,k as Yt,l as Tt,m as Zt,n as st,o as qt,p as Rt,q as Q,r as xt,s as St,t as Et}from"./chunk-GITDH3PJ.js";import{a as ot,h as jt,i as Kt,u as b}from"./chunk-HMP3VGTF.js";import{b as Ce,e as U,g as $t}from"./chunk-3GWA5OKQ.js";var K=Ce(Oe(),1);var lt=0,mt=!1,ft=!1;function Jt(){ft=!0}function Qt(t){t.cancelable&&t.preventDefault()}function dt(t){t.touches.length>0||(ft=!1,lt===0&&te())}function Le(){mt||(mt=!0,ft=!1,document.addEventListener("touchstart",Jt,{capture:!0,passive:!0}),document.addEventListener("touchmove",Qt,{capture:!0,passive:!1}),document.addEventListener("touchend",dt,{capture:!0,passive:!0}),document.addEventListener("touchcancel",dt,{capture:!0,passive:!0}))}function te(){mt&&(mt=!1,document.removeEventListener("touchstart",Jt,{capture:!0}),document.removeEventListener("touchmove",Qt,{capture:!0}),document.removeEventListener("touchend",dt,{capture:!0}),document.removeEventListener("touchcancel",dt,{capture:!0}))}function Mt(){if(typeof document>"u")return()=>{};lt+=1,Le();let t=!1;return()=>{t||(t=!0,lt-=1,lt===0&&!ft&&te())}}var ee=t=>Number(t.toFixed(4)),_e=(t,e,n)=>t+(e-t)*n;function At(t){let e=t.trim().split(/\s+/).map(s=>Number.parseFloat(s)).filter(s=>Number.isFinite(s)&&s>=0),[n=0,r=n,o=n,i=r]=e;return[n,r,o,i]}function ne(t,e){return e>0?t/e:0}function re(t,e,n,r){let{w0:o,h0:i,w:s,h:u,w1:c,h1:g}=r,d=Math.min(o,i),$=Math.min(c,g),T=Math.min(s,u),E=s>0?s:1,M=u>0?u:1,N=t.map((l,y)=>_e(ne(l,d),ne(e[y],$),n)*T),v=N.map(l=>ee(l*c/E)),x=N.map(l=>ee(l*g/M));return`${v.map(l=>`${l}px`).join(" ")} / ${x.map(l=>`${l}px`).join(" ")}`}var et="data-ramka-vt-composited",nt="data-ramka-vt-composited-css",B={group:"ramka-vt-cm-group",radius:"ramka-vt-cm-radius",old:"ramka-vt-cm-old",new:"ramka-vt-cm-new"},C=null,j=null,oe=null;function ae(){if(C)for(;C.cssRules.length>0;)C.deleteRule(C.cssRules.length-1)}function It(){if(!(typeof document>"u"||!Tt())){if(j!=null&&(clearTimeout(j),j=null),!C){C=new CSSStyleSheet,document.adoptedStyleSheets=[...document.adoptedStyleSheets,C];return}ae()}}function ke(){!C||C.cssRules.length===0||(j!=null&&clearTimeout(j),j=setTimeout(()=>{j=null,!(document.documentElement.hasAttribute(nt)||document.documentElement.hasAttribute(b.viewTransition))&&ae()},1500))}function De(t){if(Tt()){C||It();for(let e of t)C.insertRule(e,C.cssRules.length);return}oe?.release(),oe=Zt(t.join(`
`),"data-ramka-vt-composited-css")}var Ft="inset: 0 auto auto 0 !important;",z=`::view-transition-group(${O})`,Pt=`::view-transition-old(${O})`,Ct=`::view-transition-new(${O})`;function Ve(){return typeof window<"u"&&window.__RAMKA_VT_COMPOSITED__!==!1}function ie(){return typeof window<"u"&&"GestureEvent"in window}function pt(t,e,n,r){let o=n==="borderRadius"?"border-radius":"transform",i=e.map((s,u)=>{let c=r&&(u===0||u===e.length-1)?` ${r}`:"";return`${(s.offset*100).toFixed(3)}% { ${o}: ${String(s[n])};${c} }`}).join(`
`);return`@keyframes ${t} {
${i}
}`}function We(){st("data-ramka-vt-composited-style",()=>`
:root[${et}]${z} {
  animation: none !important;
  transform-origin: 0 0 !important;
}
:root[${et}]:not([${b.crossfade}])${Pt},
:root[${et}]:not([${b.crossfade}])${Ct} {
  width: auto !important;
  height: auto !important;
  ${Ft}
  transform-origin: 0 0 !important;
  animation: none !important;
}
`)}function Be(){let t=`
  animation-duration: var(${U.vtDuration}, ${it.default.duration}ms) !important;
  animation-timing-function: linear !important;
  animation-delay: 0s !important;
  animation-fill-mode: both !important;`;st("data-ramka-vt-composited-css-static",()=>`
:root[${nt}]${z} {
  transform-origin: 0 0 !important;
  animation-name: ${B.group}, ${B.radius} !important;${t}
}
:root[${nt}]:not([${b.crossfade}])${Pt} {
  ${Ft}
  transform-origin: 0 0 !important;
  animation-name: ${B.old} !important;${t}
}
:root[${nt}]:not([${b.crossfade}])${Ct} {
  ${Ft}
  transform-origin: 0 0 !important;
  animation-name: ${B.new} !important;${t}
}
`)}var G=.001;function Nt(t){if(typeof t!="string")return null;let e=t.trim(),n=/^matrix\(([^)]+)\)$/.exec(e);if(n){let r=n[1].split(",").map(d=>Number.parseFloat(d));if(r.length!==6||r.some(d=>!Number.isFinite(d)))return null;let[o,i,s,u,c,g]=r;return Math.abs(i)>G||Math.abs(s)>G||o<=0||u<=0?null:{sx:o,sy:u,tx:c,ty:g}}if(n=/^matrix3d\(([^)]+)\)$/.exec(e),n){let r=n[1].split(",").map(i=>Number.parseFloat(i));return r.length!==16||r.some(i=>!Number.isFinite(i))||[r[1],r[2],r[3],r[4],r[6],r[7],r[8],r[9],r[11],r[14]].some(i=>Math.abs(i)>G)||Math.abs(r[10]-1)>G||Math.abs(r[15]-1)>G||r[0]<=0||r[5]<=0?null:{sx:r[0],sy:r[5],tx:r[12],ty:r[13]}}return null}function tt(t){if(typeof t!="string")return null;let e=Number.parseFloat(t);return Number.isFinite(e)&&e>0?e:null}var ht=1.5;function se(t,e,n,r){if(!r.isConnected||Math.abs(t.sx-1)>G||Math.abs(t.sy-1)>G)return null;let o;try{o=r.getBoundingClientRect()}catch{return null}return!(o.width>0&&o.height>0)||Math.abs(o.width-e)>ht||Math.abs(o.height-n)>ht||Math.abs(o.left-t.tx)<=ht&&Math.abs(o.top-t.ty)<=ht?null:{sx:1,sy:1,tx:o.left,ty:o.top}}var P=t=>Number(t.toFixed(4));function Ot(t,e,n){Ve()&&t.ready&&t.ready.then(()=>He(t,e,n??null)).catch(()=>{})}function He(t,e,n){let r=document.documentElement,o=r.hasAttribute(b.crossfade);if(typeof document.getAnimations!="function")return;let s=document.getAnimations().filter(a=>a.effect?.pseudoElement===z).find(a=>(a.animationName??"").startsWith("-ua-view-transition-group-anim"));if(!s||!s.effect)return;let u=s.effect,c=[];try{c=u.getKeyframes()}catch{c=[]}let g=c.find(a=>(a.computedOffset??a.offset??0)===0);if(!g)return;let d=Nt(g.transform),$=tt(g.width),T=tt(g.height);if(!d||$==null||T==null)return;let E=u.getComputedTiming(),M=typeof E.duration=="number"?E.duration:NaN;if(!Number.isFinite(M)||M<=0)return;let{duration:N,ease:v}=Yt(),x=s.currentTime,l=typeof x=="number"&&Number.isFinite(x)?Math.max(0,Math.min(x,M)):0,y=c.find(a=>(a.computedOffset??a.offset)===1),m=y?Nt(y.transform):null,f=y?tt(y.width):null,p=y?tt(y.height):null;if(!m||f==null||p==null){s.pause(),s.currentTime=M;let a=getComputedStyle(r,z);if(m=Nt(a.transform),f=tt(a.width),p=tt(a.height),!m||f==null||p==null){s.currentTime=0,s.play();return}}if(n&&ie()){let a=r.getAttribute(b.viewTransition);a==="opening"?d=se(d,$,T,n)??d:a==="closing"&&(m=se(m,f,p,n)??m)}let F=getComputedStyle(r,z),k=F.transformOrigin.split(" ").map(a=>Number.parseFloat(a)),D=Number.parseFloat(F.width),L=Number.parseFloat(F.height),_=Number.isFinite(k[0])&&Number.isFinite(D)&&D>0?k[0]/D:.5,V=Number.isFinite(k[1])&&Number.isFinite(L)&&L>0?k[1]/L:.5;s.cancel();let S=ie();S||(We(),r.setAttribute(et,""));let I=At(e?.from??""),rt=At(e?.to??""),X=[...I,...rt].some(a=>a>0),Y=Math.min(120,Math.max(24,Math.round(N/8))),Z=[],h=[],A=[],q=[],W=(a,R,w)=>a+(R-a)*w,J=d,at=m,xe=a=>{let R=W($,f,a),w=W(T,p,a),Dt=W(J.sx,at.sx,a),Vt=W(J.sy,at.sy,a),Se=W(J.tx,at.tx,a),Ee=W(J.ty,at.ty,a),Me=R*Dt,Ae=w*Vt,Ne=Se+_*R*(1-Dt),Fe=Ee+V*w*(1-Vt),Wt=null;X&&(Wt=re(I,rt,a,{w0:$,h0:T,w:R,h:w,w1:f,h1:p}));let Bt=(Ht,Ut)=>{let ct=Math.max(R/Ht,w/Ut),Ie=(R-ct*Ht)/2*f/R,Pe=(w-ct*Ut)/2*p/w;return`translate(${P(Ie)}px, ${P(Pe)}px) scale(${P(ct*f/R)}, ${P(ct*p/w)})`};return{group:`translate(${P(Ne)}px, ${P(Fe)}px) scale(${P(Me/f)}, ${P(Ae/p)})`,radius:Wt,old:Bt($,T),new:Bt(f,p)}};for(let a=0;a<=Y;a++){let R=a/Y,w=xe(v(R));Z.push({offset:R,transform:w.group}),X&&h.push({offset:R,borderRadius:w.radius}),o||(A.push({offset:R,transform:w.old}),q.push({offset:R,transform:w.new}))}let ut=a=>({duration:N,easing:"linear",fill:"both",pseudoElement:a}),H=[];if(S){Be();let a=[pt(B.group,Z,"transform"),pt(B.radius,X?h:[],"borderRadius")];o||a.push(pt(B.old,A,"transform",`width: ${P($)}px; height: ${P(T)}px;`),pt(B.new,q,"transform",`width: ${P(f)}px; height: ${P(p)}px;`)),De(a),r.setAttribute(nt,"")}else{try{H.push(r.animate(Z,ut(z))),X&&H.push(r.animate(h,ut(z))),o||(H.push(r.animate(A,ut(Pt))),H.push(r.animate(q,ut(Ct))))}catch{for(let w of H)w.cancel();r.removeAttribute(et),s.currentTime=0,s.play();return}let a=document.timeline?.currentTime,R=ot()&&typeof a=="number";for(let w of H)R?w.startTime=a-l:l>0&&(w.currentTime=l)}t.finished.finally(()=>{for(let a of H)a.cancel();r.removeAttribute(et),r.removeAttribute(nt),ke()})}function Ue(t){let e=t.trim();return e!==""&&e.toLowerCase()!=="none"}function ce(t){let e=t.style;if(e&&Ue(e.getPropertyValue("view-transition-name")))return!0;let n=t.styleSheet;if(n&&le(n))return!0;let r=t.cssRules;if(r){for(let o of Array.from(r))if(ce(o))return!0}return!1}function le(t){let e;try{e=t.cssRules}catch{return!1}for(let n of Array.from(e))if(ce(n))return!0;return!1}function ue(t){for(let e of t)if(le(e))return!0;return!1}var gt=null;function ze(t){return`${t.styleSheets.length}/${t.adoptedStyleSheets?.length??0}`}function me(t=document){if(t.querySelector('[style*="view-transition-name"]'))return!0;let e=ze(t);if(gt&&gt.key===e)return gt.result;let n=ue(Array.from(t.styleSheets))||ue(t.adoptedStyleSheets??[]);return gt={key:e,result:n},n}function de(t){return document.startViewTransition(t)}var je=8,fe=1e3;function pe(){let t=typeof window<"u"?window.visualViewport:null;return{innerW:window.innerWidth,innerH:window.innerHeight,vvH:t?.height??null,scrollX:Math.round(window.scrollX),scrollY:Math.round(window.scrollY)}}function he(t){return`${t.innerW}x${t.innerH}|vv:${t.vvH??"n"}|s:${t.scrollX},${t.scrollY}`}function Ke(t){return t.vvH==null?!0:Math.abs(t.innerH-t.vvH)<=1}function Xe(){return typeof navigator<"u"&&/jsdom/i.test(navigator.userAgent)?Promise.resolve():new Promise(t=>{let e=performance.now(),n=he(pe()),r=0,o=()=>{let i=pe(),s=he(i),u=Ke(i),c=performance.now()-e;if(s===n&&u?r+=1:(n=s,r=0),r>=je||c>=fe&&u||c>=fe*1.5){t();return}requestAnimationFrame(o)};requestAnimationFrame(o)})}function Ye(){return typeof navigator<"u"&&/jsdom/i.test(navigator.userAgent)?!1:zt()}function Ze(t,e=200){if(!t)return Promise.resolve();let n=t.tagName==="IMG"?t:t.querySelector("img");return!n||!("decode"in n)||n.complete&&n.naturalWidth>0?Promise.resolve():new Promise(r=>{let o=!1,i=()=>{o||(o=!0,r())};n.decode().then(i,i),setTimeout(i,e)})}function qe(t){if(!t)return null;let e=t.tagName==="IMG"?t:t.querySelector("img");return!e||!("decode"in e)||e.complete&&e.naturalWidth>0?null:e}function Te(t){if(!t)return!1;let e=t.getBoundingClientRect();return e.width>0&&e.height>0}var Lt=null,_t=null;function Je(t,e){!Lt||e!==t||Lt.has(t)||(Lt.add(t),console.warn("[ramka] Lightbox.Item is morphing into its own element (the full <Lightbox.Item> box) because no morph target was designated. Wrap the destination media in <Lightbox.Media> (recommended), or attach `imageRef` / `morphRef` on Lightbox.Item so the trigger morphs into the media instead.",t))}function Qe(t){if(!_t||!t)return;let e=t.hasAttribute("data-ramka-media")?t:t.closest("[data-ramka-media]");!e||_t.has(e)||Te(t)||(_t.add(e),console.warn("[ramka] Lightbox.Media morph target has no resolvable size (0\xD70). Pass `width`/`height` on Media (or HTML width/height on the child <img>) and nest Media under Lightbox.Zoom (a size container) so the fit-box can resolve. Falling back to a root crossfade.",e))}function ge(t,e){return t==="both"?!0:e==="opening"?t==="open":t==="close"}function tn(t){let e=[],n="",r=0;for(let o of t){if(o==="("?r+=1:o===")"&&(r=Math.max(0,r-1)),/\s/.test(o)&&r===0){n&&e.push(n),n="";continue}n+=o}return n&&e.push(n),e}var kt=1e9;function en(t,e,n){let r=t.trim().toLowerCase();if(!r)return 0;if(/infinity/i.test(r))return kt;if(r.endsWith("%")){let i=Number.parseFloat(r);return Number.isFinite(i)?Math.max(0,n*i/100):kt}let o=Number.parseFloat(r);if(!Number.isFinite(o))return kt;if(r.endsWith("rem")){let i=Number.parseFloat(getComputedStyle(document.documentElement).fontSize)||16;return Math.max(0,o*i)}if(r.endsWith("em")){let i=Number.parseFloat(getComputedStyle(e).fontSize)||16;return Math.max(0,o*i)}return Math.max(0,o)}function nn(t){return Math.round(t*100)/100}function vt(t){let e=getComputedStyle(t).borderRadius.trim();if(!e)return"0px";let{width:n,height:r}=t.getBoundingClientRect();if(!(n>0&&r>0))return"0px";let o=e.split("/")[0].trim(),i=tn(o);if(i.length===0)return"0px";let[s,u=s,c=s,g=u]=i,[d,$,T,E]=[s,u,c,g].map(f=>en(f,t,n)),M=Math.min(1,n/(d+$),n/(E+T),r/($+T),r/(d+E)),N=[d,$,T,E].map(f=>nn(f*M)),[v,x,l,y]=N,m;return y===x?l===v?m=x===v?[v]:[v,x]:m=[v,x,l]:m=[v,x,l,y],m.map(f=>`${f}px`).join(" ")}function rn(t,e){t.setAttribute(b.viewTransitionPreset,Xt(e)?e:"default")}function ve(t,e,n){t.style.getPropertyValue(e)!==n&&t.style.setProperty(e,n)}var be=.5,on=1;function sn(t){let e=t.offsetWidth,n=t.offsetHeight;if(!(e>0&&n>0))return{horizontal:!1,vertical:!1};let r=document.documentElement.clientWidth,o=document.documentElement.clientHeight;return{horizontal:e>=r-be,vertical:n>=o-be}}function ye(t){if(!ot())return null;let e=sn(t);if(!e.horizontal&&!e.vertical)return null;let n=t.closest(`[${Kt.slide}]`)??t,r=n.style.paddingLeft,o=n.style.paddingRight,i=n.style.paddingTop,s=n.style.paddingBottom,u=getComputedStyle(n),c=on;return e.horizontal&&(n.style.paddingLeft=`${(parseFloat(u.paddingLeft)||0)+c}px`,n.style.paddingRight=`${(parseFloat(u.paddingRight)||0)+c}px`),e.vertical&&(n.style.paddingTop=`${(parseFloat(u.paddingTop)||0)+c}px`,n.style.paddingBottom=`${(parseFloat(u.paddingBottom)||0)+c}px`),t.offsetWidth,()=>{n.style.paddingLeft=r,n.style.paddingRight=o,n.style.paddingTop=i,n.style.paddingBottom=s}}var Re=0;function we(t,e,n){let r=me();t.setAttribute(b.viewTransition,e),rn(t,n.preset),n.useCrossfade&&t.setAttribute(b.crossfade,""),r&&t.setAttribute(b.viewTransitionIsolate,""),It();let o=(e==="opening"?n.fromRadius:n.toRadius)??"0px",i=(e==="opening"?n.toRadius:n.fromRadius)??"0px";return ve(t,U.morphRadiusTrigger,o),ve(t,U.morphRadiusItem,i),++Re}function bt(t){t.style.setProperty("view-transition-name",O,"important")}function yt(t){t.style.removeProperty("view-transition-name")}function $e(t,e){e===Re&&(t.removeAttribute(b.viewTransition),t.removeAttribute(b.crossfade),t.removeAttribute(b.viewTransitionPreset),t.removeAttribute(b.viewTransitionIsolate))}function an(t){let e=async()=>{let{decodeMaxWait:o,onBeforeOpenRef:i,beforeOpenAbortRef:s,triggerElementsRef:u,triggerMorphElementsRef:c,activeItemElementRef:g,itemMorphElementsRef:d,openingTriggerIndexRef:$,openingTriggerElementRef:T,closeGenRef:E,commitPrepare:M,commitReveal:N,commitAbortPrepare:v}=t(),x=document.documentElement,l=E.current,y=Mt(),m=new AbortController;s.current=m;let f=$.current,p=T.current??u.current.get(f)??void 0,F=p?Rt(p,c.current):null,k=ge(p?.dataset.crossfade,"opening"),D=F?vt(F):null;(0,K.flushSync)(M);let L=!1;if(o>0){let h=g.current,A=h?qt(h,d.current):null;if(qe(A)&&(await Ze(A,o),L=!0,t().closeGenRef.current!==l)){s.current===m&&(s.current=null),y();return}}let _=i.current;if(_){let h=g.current,A=Q(h,d.current,t().destinationMorphElementRef.current);try{await _({destination:A,signal:m.signal}),L=!0}catch{s.current===m&&(s.current=null),t().closeGenRef.current===l&&(0,K.flushSync)(v),y();return}if(s.current===m&&(s.current=null),t().closeGenRef.current!==l){y();return}if(m.signal.aborted){(0,K.flushSync)(v),y();return}}else s.current===m&&(s.current=null);if(Ye()&&(await Xe(),L=!0,t().closeGenRef.current!==l)){(0,K.flushSync)(v),y();return}if(wt()&&(await Gt(L?1:2),t().closeGenRef.current!==l)){y();return}let V=g.current,S=Q(V,d.current,t().destinationMorphElementRef.current),I=!!F&&Te(S);I&&V&&S===V&&Je(V,S),I||Qe(S);let rt=I?vt(S):null,X=we(x,"opening",{useCrossfade:I?k:!0,fromRadius:I?D:null,toRadius:rt,preset:t().transitionPreset});I&&bt(F);let Y=null,Z=de(()=>{I&&yt(F),(0,K.flushSync)(N);let h=g.current;if(I){let A=Q(h,d.current,t().destinationMorphElementRef.current);A&&(bt(A),Y=ye(A))}h&&h.setAttribute("data-skip-fade","")});I&&Ot(Z,{from:D,to:rt},F),Z.finished.finally(()=>{if(y(),Y?.(),Y=null,t().closeGenRef.current!==l)return;let h=t(),A=h.activeItemElementRef.current,q=Q(A,h.itemMorphElementsRef.current,h.destinationMorphElementRef.current);q&&yt(q),$e(x,X);let W=xt(h.scrollTriggerIntoView,"onOpenComplete");if(W){let J=Et(h.activeIndexRef.current,h.morphTo,h.openingTriggerIndexRef.current,h.triggerElementsRef.current);St(h.triggerElementsRef.current.get(J),W)}h.onOpenComplete()})},n=()=>{let o=t().closeGenRef.current,i=Mt();if(wt()){requestAnimationFrame(()=>{if(t().closeGenRef.current!==o){i();return}r(o,i)});return}r(o,i)},r=(o,i)=>{let{morphTo:s,scrollTriggerIntoView:u,triggerElementsRef:c,triggerMorphElementsRef:g,activeItemElementRef:d,itemMorphElementsRef:$,destinationMorphElementRef:T,openingTriggerIndexRef:E,activeIndexRef:M,commitClose:N}=t(),v=document.documentElement,x=d.current,l=Q(x,$.current,T.current),y=Et(M.current,s,E.current,c.current),m=c.current.get(y),f=m?Rt(m,g.current):null,p=!!f&&!!l,F=p?ge(m?.dataset.crossfade,"closing"):!0,k=p?vt(l):null,D=p?vt(f):null,L=we(v,"closing",{useCrossfade:F,fromRadius:k,toRadius:D,preset:t().transitionPreset});if(ot()){let S=t().activeZoomRef.current;S&&S.getZoom()>1&&S.reset(!0)}let _=null;p&&(_=ye(l),bt(l));let V=de(()=>{_?.(),_=null,p&&yt(l),(0,K.flushSync)(N);let S=xt(u,"onClose");S&&St(m,S),p&&bt(f)});p&&Ot(V,{from:k,to:D},f),V.finished.finally(()=>{i(),_?.(),_=null,p&&yt(f),$e(v,L),t().closeGenRef.current===o&&t().onCloseComplete(m)})};return{open:e,close:n}}var un="data-ramka-lightbox-vt-styles";function cn(){let t=b.viewTransition,e=b.viewTransitionIsolate,n=b.crossfade,r=jt.slides,o=U,i=it.default,s=`::view-transition-group(${O})`,u=`::view-transition-old(${O})`,c=`::view-transition-new(${O})`,g=`var(${o.vtDuration}, ${i.duration}ms)`,d=`var(${o.vtEasing}, ${i.cssEasing})`,$=`var(${o.vtCrossfadeCloseEasing}, ${i.cssCrossfadeCloseEasing})`,T=`var(${o.vtRootEasing}, ${i.cssRootEasing})`,E=`calc(${g} * 0.48)`,M=Object.entries(it).map(([N,v])=>`
:root[${b.viewTransitionPreset}="${N}"]::view-transition {
  ${o.vtDuration}: ${v.duration}ms;
  ${o.vtEasing}: ${v.cssEasing};
  ${o.vtCrossfadeCloseEasing}: ${v.cssCrossfadeCloseEasing};
  ${o.vtRootEasing}: ${v.cssRootEasing};
}`).join(`
`);return`
/* Isolate the lightbox morph from the rest of the page. startViewTransition
   captures the WHOLE document, so any consumer element carrying its own
   view-transition-name would be lifted into a separate group and painted on
   the VT layer over the backdrop. Neutralize every name while the morph runs;
   the morph target re-declares its name inline with !important, which
   outranks this author-!important rule on specificity.

   Armed via its own attribute \u2014 NOT ${t} \u2014 and only when the page actually
   declares foreign names (see vt-name-isolation.ts). Flipping a root
   attribute that a universal descendant rule keys on invalidates style for
   the entire document \u2014 at 20k elements that's a ~120ms restyle at capture
   and another ~60ms at teardown, in every engine. Pages with no names to
   neutralize (the overwhelmingly common case) skip that bill entirely. */
:root[${e}] * {
  view-transition-name: none !important;
}

${M}

/* Hard-cut snapshot opacities and the radius from/to derivation, by phase
   (see the hard-cut rules below and applyMorphState for the rationale).
   Published on the ::view-transition pseudo instead of inline on <html> \u2014
   see the preset-timing comment above. Under crossfade the opacity vars are
   inert anyway (the crossfade rules override the consuming 'opacity'
   declarations with 'revert !important'), so they can be keyed on the phase
   attribute alone. The trigger/item radius pair is inline on <html> (per
   morph, deduplicated); the pseudo inherits from the root element, so the
   var() references resolve. */
:root[${t}]::view-transition {
  ${o.morphOldOpacity}: 1;
}

:root[${t}="opening"]::view-transition {
  ${o.morphNewOpacity}: 1;
  ${o.morphBorderRadiusFrom}: var(${o.morphRadiusTrigger}, 0px);
  ${o.morphBorderRadiusTo}: var(${o.morphRadiusItem}, 0px);
}

:root[${t}="closing"]::view-transition {
  ${o.morphNewOpacity}: 0;
  ${o.morphBorderRadiusFrom}: var(${o.morphRadiusItem}, 0px);
  ${o.morphBorderRadiusTo}: var(${o.morphRadiusTrigger}, 0px);
}

/* The morph-target hide rule (opacity zero plus its during-VT transition
   kill) is NOT in this sheet: it must exist before any morph runs \u2014 a page
   that server-renders an open lightbox has a morph target but no transition
   yet \u2014 so Lightbox.Trigger delivers it eagerly. See morph-target-hide.ts. */

@media (prefers-reduced-motion: no-preference) {
  /* Root snapshot cross-fade \u2014 the page-behind transition. Kept as a SINGLE
     root group: WebKit rasterizes each named group on the CPU. Lightbox
     chrome (thumbnails, zoom controls) fades with this snapshot \u2014 never as
     its own fullscreen named group. */
  :root[${t}]::view-transition-old(root),
  :root[${t}]::view-transition-new(root) {
    animation-duration: ${g};
    animation-timing-function: ${T};
  }

  /* Shape morph is CSS-only: JS writes the from/to radius vars; the group
     owns clipping for the whole transition. The 'from' radius is the cascade
     base (not only a keyframe) so frame 0 can't flash the 0px fallback. */
  @keyframes ramka-morph-border-radius {
    to {
      border-radius: var(${o.morphBorderRadiusTo}, 0px);
    }
  }

  ${s} {
    overflow: hidden;
    border-radius: var(${o.morphBorderRadiusFrom}, 0px);
    animation-name: -ua-view-transition-group-anim-${O}, ramka-morph-border-radius;
    animation-duration: ${g};
    animation-timing-function: ${d};
    animation-fill-mode: both;
    z-index: 2;
  }

  /* Hard-cut default (Trigger omits crossfade). Cover keeps same-image crops
     coherent; kill the UA dissolve and drive opacity from library vars. */
  ${u},
  ${c} {
    object-fit: cover;
    width: 100%;
    height: 100%;
    animation: none !important;
    mix-blend-mode: normal;
  }

  ${u} {
    opacity: var(${o.morphOldOpacity}, 1);
  }

  ${c} {
    opacity: var(${o.morphNewOpacity}, 0);
  }

  /* Dissolve path (Trigger crossfade): restore the UA fade, plus-lighter
     blend, fill so circular triggers don't balloon under cover. Re-timed to
     the preset vars so the dissolve runs on the morph's clock (the UA
     default would end at 250ms, mid-morph). Open uses the morph ease-out so
     the destination appears promptly while the group grows; close uses a
     modest ease-out (not the morph curve \u2014 that flashes a stretched trigger
     in the first frames, and a strong ease-in holds the item too long).
     Both phases share one complementary 1\u21920 / 0\u21921 pair on a shorter window
     so the outgoing snapshot is gone before the size settle (a face or +N
     overlay must not ghost until t=1). Do not delay one snapshot relative
     to the other \u2014 that leaves a window where opacities no longer sum to 1.

     Fill-mode both: the UA fades run with fill none, so a finished fade
     snaps the old snapshot back to its base opacity of 1 \u2014 and the
     composited group replacement can outlive the fades by a frame (its
     animations attach one style flush later), which painted a fully-opaque
     trigger snapshot blended over the item for that frame. Holding the end
     state closes the gap. */
  :root[${n}]${u},
  :root[${n}]${c} {
    object-fit: fill;
    mix-blend-mode: plus-lighter;
    animation: revert !important;
    animation-duration: ${E} !important;
    animation-timing-function: ${d} !important;
    animation-fill-mode: both !important;
    opacity: revert;
  }

  :root[${t}="closing"][${n}]${u},
  :root[${t}="closing"][${n}]${c} {
    animation-timing-function: ${$} !important;
  }
}

/* Thumb-jump slides crossfade \u2014 the element-scoped view transition started by
   ThumbnailStrip's selectViewTransition. Tunable via the select-vt vars. */
[${r}]::view-transition-group(root) {
  animation-duration: var(${$t.selectVtDuration}, 0.4s);
  animation-timing-function: var(${$t.selectVtEasing}, cubic-bezier(0.22, 1, 0.36, 1));
}

[${r}]::view-transition-old(root),
[${r}]::view-transition-new(root) {
  mix-blend-mode: normal;
  height: 100%;
  overflow: clip;
}
`}function ln(){st(un,cn,!0)}export{an as createViewTransitionMorph,ln as ensureVtStructuralStyles};
