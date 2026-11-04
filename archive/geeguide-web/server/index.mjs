import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {resolve,extname,sep} from 'node:path';
import {openCatalog,readCatalog} from './database.mjs';
export function createApp(db,{production=false}={}) {
 const root=fileURLToPath(new URL('../dist/',import.meta.url));
 return createServer(async(req,res)=>{
  res.setHeader('X-Content-Type-Options','nosniff');res.setHeader('Referrer-Policy','no-referrer');res.setHeader('X-Frame-Options','DENY');res.setHeader('Permissions-Policy','camera=(), microphone=(), geolocation=()');
  if(production)res.setHeader('Content-Security-Policy',"default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'");
  const json=(status,body)=>{res.writeHead(status,{'Content-Type':'application/json','Cache-Control':'no-store'});res.end(JSON.stringify(body));};
  if(!['GET','HEAD'].includes(req.method)){res.setHeader('Allow','GET, HEAD');return json(405,{error:'Read-only service'});}
  let pathname;try{pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);}catch{return json(400,{error:'Invalid path'});}
  if(pathname==='/api/catalog')return json(200,readCatalog(db));
  if(pathname==='/api/health')return json(200,{status:'ok',storage:'sqlite',personalDataStored:false});
  if(pathname.startsWith('/api/'))return json(404,{error:'Not found'});
  if(!production)return json(404,{error:'Use the Vite frontend on port 5173'});
  const file=resolve(root,'.'+pathname);
  if(!file.startsWith(root.endsWith(sep)?root:root+sep))return json(403,{error:'Forbidden'});
  const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.svg':'image/svg+xml','.json':'application/json','.png':'image/png'};
  try {let path=file;if(pathname==='/'||!extname(pathname))path=resolve(root,'index.html');const data=await readFile(path);res.writeHead(200,{'Content-Type':types[extname(path)]||'application/octet-stream','Cache-Control':'no-cache'});res.end(req.method==='HEAD'?undefined:data);}catch{json(404,{error:'Not found'});}
 });
}
if(process.argv[1]===fileURLToPath(import.meta.url)){
 const production=process.argv.includes('--production');const db=openCatalog(fileURLToPath(new URL('../data/catalog.sqlite',import.meta.url)));
 const port=Number(process.env.PORT|| (production?4173:4174));createApp(db,{production}).listen(port,'127.0.0.1',()=>console.log(`GeeGuide ${production?'demo':'API'}: http://127.0.0.1:${port}`));
}
