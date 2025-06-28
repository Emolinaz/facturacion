<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class FacturaController extends Controller
{
    private $apiUrl = "http://localhost:3001/api";

    public function index()
    {
        return view('Pages.generador-facturas');
    }

    public function estadisticas()
    {
        $data = Http::get("$this->apiUrl/facturas/estadisticas")->json();
        return response()->json($data);
    }

    public function clientes()
    {
        $data = Http::get("$this->apiUrl/clientes")->json();
        return response()->json($data);
    }

    public function empleados()
    {
        $data = Http::get("$this->apiUrl/empleados")->json();
        return response()->json($data);
    }

    public function productos(Request $req)
    {
        $tipo = $req->query('tipo');
        $url = "$this->apiUrl/productos";
        if ($tipo) $url .= "?tipo=$tipo";
        $data = Http::get($url)->json();
        return response()->json($data);
    }

    public function eventos()
    {
        $data = Http::get("$this->apiUrl/eventos")->json();
        return response()->json($data);
    }

    public function cai()
    {
        $data = Http::get("$this->apiUrl/cai")->json();
        return response()->json($data);
    }

    public function boletosTaquilla()
    {
        $data = Http::get("$this->apiUrl/boletos-taquilla")->json();
        return response()->json($data);
    }

    public function crear(Request $req)
    {
        $data = $req->all();
        $resp = Http::post("$this->apiUrl/facturas", $data);
        return response()->json($resp->json(), $resp->status());
    }
}
