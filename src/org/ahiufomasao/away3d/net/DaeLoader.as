package org.ahiufomasao.away3d.net 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.DAEParser;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.ahiufomasao.utility.net.ILoader;
	
	// TODO: asdoc
	// TODO: テスト
	/**
	 * <code>DaeLoader</code> クラスは、Away3D で Collada 形式のデータのロードまたはパース機能を提供します.
	 * 
	 * @author asahiufo/AM902
	 */
	public class DaeLoader extends EventDispatcher implements ILoader
	{
		private var _ns:String;
		private var _source:Object;
		private var _assetLoaderContext:AssetLoaderContext;
		
		private var _mesh:Mesh;
		private var _objectContainer:ObjectContainer3D;
		
		private var _loader:Loader3D;
		private var _complete:Boolean; // ロードが完了しているならtrue
		
		/**
		 * 常に 0 です。
		 */
		public function get bytesLoaded():uint { return 0; }
		/**
		 * 常に 0 です。
		 */
		public function get bytesTotal():uint { return 0; }
		/**
		 * @inheritDoc
		 */
		public function get loading():Boolean
		{
			if (complete)
			{
				return false;
			}
			else if (_loader == null)
			{
				return false;
			}
			return true;
		}
		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean { return _complete; }
		/**
		 * 読み込まれた Asset データ（<code>ObjectContainer3D</code> オブジェクト）です.
		 * <p>
		 * ロードが完了するまでは <code>null</code> です。
		 * </p>
		 */
		public function get data():Object
		{
			return _objectContainer;
		}
		
		/**
		 * 新しい <code>DaeLoader</code> クラスのインスタンスを生成します.
		 * 
		 * @param ns                 ネームスペース
		 * @param source             パース対象オブジェクト
		 * @param assetLoaderContext アセットローダーコンテキスト
		 */
		public function DaeLoader(ns:String, source:Object, assetLoaderContext:AssetLoaderContext = null)
		{
			_ns                 = ns;
			_source             = source;
			_assetLoaderContext = assetLoaderContext;
			
			_mesh            = null;
			_objectContainer = null;
		
			_loader   = null;
			_complete = false;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * @throws IllegalOperationError <code>load</code> メソッドを 2 回以上実行した場合にスローされます。
		 */
		public function load():void
		{
			if (_loader != null)
			{
				throw new IllegalOperationError("ロードは実施済みです。");
			}
			
			_loader = new Loader3D();
			_loader.addEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);
			_loader.addEventListener(LoaderEvent.LOAD_ERROR, _onLoadError);
			_loader.loadData(_source, _assetLoaderContext, _ns, new DAEParser());
		}
		
		/**
		 * @private
		 * アセットコンプリートイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onAssetComplete(event:AssetEvent):void
		{
			var assetType:String = event.asset.assetType;
			if (assetType == AssetType.TEXTURE)
			{
			}
			else if (assetType == AssetType.MATERIAL)
			{
			}
			else if (assetType == AssetType.GEOMETRY)
			{
			}
			else if (assetType == AssetType.MESH)
			{
				_mesh = event.asset as Mesh;
			}
			else if (assetType == AssetType.CONTAINER)
			{
				_objectContainer = event.asset as ObjectContainer3D;
			}
		}
		
		/**
		 * @private
		 * リソースコンプリートイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onResourceComplete(event:LoaderEvent):void
		{
			_loader.removeEventListener(LoaderEvent.LOAD_ERROR, _onLoadError);
			_loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);
			_loader.removeEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);
			
			_complete = true;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * @private
		 * ロードエラーイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onLoadError(event:LoaderEvent):void
		{
			throw new SecurityError("ロードエラーが発生しました。[" + event.toString() + "]");
		}
		
		/**
		 * 読み込んだデータの複製を取得します.
		 * 
		 * @return 読み込んだデータの複製
		 * 
		 * @throws IllegalOperationError ロード未完了の状態で実行した場合にスローされます。
		 */
		public function cloneData():Object
		{
			if (!complete)
			{
				throw new IllegalOperationError("ロードが完了していません。");
			}
			
			// TODO: AssetLibrary.getAsset()でやんの？
			return data;
		}
		
		/**
		 * <code>DaeLoader</code> オブジェクトのプロパティを含むストリングを返します.
		 * <p>
		 * ストリングは次の形式です。
		 * </p>
		 * <p>
		 * <code>[DaeLoader  complete=<em>value</em> data="<em>value</em>"]</code>
		 * </p>
		 * 
		 * @return <code>DaeLoader</code> オブジェクトのプロパティを含むストリングです。
		 */
		override public function toString():String 
		{
			return ("[DaeLoader complete=" + _complete + " data=\"" + data + "\"]");
		}
	}
}
