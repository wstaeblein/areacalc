<script>
    // @ts-nocheck

    let mode = $state(0);
    const units = [{ val: 'un', lbl: 'Unidade' }, { val: 'm2', lbl: 'M²' }, { val: 'cm2', lbl: 'CM²' }, { val: 'in2', lbl: 'IN²' }];
    const units2 = units.slice(1);
    const straightUnits = [{ val: 'm', lbl: 'M' }, { val: 'cm', lbl: 'CM' }, { val: 'in', lbl: 'IN' }];
    const shapes = [{ val: 'rect', lbl: 'Retângular' }, { val: 'circ', lbl: 'Circular' }, { val: 'tria', lbl: 'Triangular' }, { val: 'hexa', lbl: 'Hexagonal' }, { val: 'trap', lbl: 'Trapezoidal' }, { val: 'arc', lbl: 'Em Arco' }]

    let mainUnit = $state({ val: 'm2', lbl: 'M²' });

    let tiles = $state({
        width: null,
        length: null,
        tileunit: 'cm',
        area: null,
        areaunit: 'm2',
        margin: null,
        price: null,
        priceunit: 'un',
        result: 0,
        resultcost: 0,
        totalarea: 0,
        ready: false
    });

    let areas = $state([
        { dim1: null, dim2: null, dim3: null, unit: 'cm', shape: 'rect' }
    ]);

    let totalAreaCm2 = $derived(areas.reduce((acc, curr) => acc += convert(curr.unit + '2-' + 'cm2', getArea(curr)), 0));


    function calcTiles() {

        if (!tiles.width || !tiles.length || !tiles.area || !tiles.width ) { return; }

        // Área de uma peça
        const itemArea = tiles.width * tiles.length;

        // Número de peças
        const itemsAreaInUnit = convert(tiles.areaunit + '-' + tiles.tileunit + '2', tiles.area); console.log('--> ', itemsAreaInUnit)
        const exactItems = itemsAreaInUnit / itemArea;

        // Número de peças com a margem
        tiles.result = Math.ceil(exactItems * (1 + (tiles.margin / 100)));


        switch (tiles.priceunit) {
            case 'un':
                tiles.resultcost = tiles.price * tiles.result;
                tiles.priceperarea = tiles.resultcost / tiles.area;
                break;
            case 'ar':
                tiles.resultcost = tiles.price * tiles.area;
                tiles.priceperarea = tiles.price;
                break;
            case 'pc':

                break;

        }
        tiles.ready = true;
    }

    function setMode(md) {
        mode = md;

    }

    function newArea(evt) {
        evt.preventDefault();
        let last = areas.at(-1).unit; 
        areas.push({ width: 0, length: 0, unit: last });
    }

    function delArea(ind, evt) {
        evt.preventDefault();
        areas.splice(ind, 1);
    }

    function convert(units, value) { console.log(units)
        switch (units) {
            case 'm-in': return value * 39.3700787;
            case 'cm-in': return value / 2.54;
            case 'in-m': return value * 0.0254;
            case 'in-cm': return value * 2.54;

            case 'm2-in2': return value * 1550.0031;
            case 'cm2-in2': return value / 6.4516;
            case 'in2-m2': return value * 0.00064516;
            case 'in2-cm2': return value * 6.4516;
            case 'cm2-m2': return value / 10000;
            case 'm2-cm2': return value * 10000;
            default: return value;
        }
    }

    function getArea(ele) {
        let d1 = ele.dim1 || 0, d2 = ele.dim2 || 0, d3 = ele.dim3 || 0;
        switch(ele.shape) {
            case 'rect': return d1 * d2;
            case 'circ': return Math.PI * d1 * (d2 || d1);
            case 'hexa': return (3 * Math.sqrt(3) * Math.pow(d1, 2)) / 2;
            case 'trap': return 0.5 * (d1 + d2) * d3;
            case 'arc': return (d1 / 360) * Math.PI * Math.pow(d2, 2);
            case 'tria': 
                let s = (d1 + d2 + d3) / 2;
                return Math.sqrt(s * (s - d1) * (s - d2) * (s - d3));
        }
    }

    function getUnit(un) {
        return units.find(u => u.val === un)?.lbl || '';
    }
</script>

<section>
    <nav>
        <div><img src="/img/logo-hor.png" height="32px" alt="Logo" /></div>
<!--         <div>
            <span>m²</span>
            <span>cm²</span>
            <span>in</span>
        </div> -->
    </nav>
    <main>
        
        <div class="tabs">
            <button onclick={setMode.bind(this, 0)}>Peças</button>
            <button onclick={setMode.bind(this, 1)}>Área</button>
        </div>

        {#if mode === 0}
            <div class="tiles">
                <div>
                <h5>Calcule quantas peças de determinado tamanho são necessárias para cobrir determinada área e por qual preço </h5>
                    <div>Entre as dimensões da peça</div>
                    <div>
                        <input type="number" bind:value={tiles.width} placeholder="Largura" step="0.01" min="0" oninput={calcTiles} />
                        <span>x</span>
                        <input type="number" bind:value={tiles.length} placeholder="Comprimento" step="0.01" min="0" oninput={calcTiles} />
                        <select bind:value={tiles.tileunit} onchange={calcTiles}>
                            {#each straightUnits as un}
                                <option value={un.val}>{un.lbl}</option>
                            {/each}
                        </select>                        
                        
                    </div>
                    
                </div>
                <div>
                    <div>Entre a área</div>
                    <input type="number" bind:value={tiles.area} placeholder="" step="0.01" min="0" oninput={calcTiles} />
                        <select bind:value={tiles.areaunit} onchange={calcTiles}>
                            {#each units2 as un}
                                <option value={un.val}>{un.lbl}</option>
                            {/each}
                        </select>                          
                </div>
                <div>
                    <div>Entre o preço</div>
                    <input type="number" bind:value={tiles.price} placeholder="" step="0.01" min="0" oninput={calcTiles} />
                    <select bind:value={tiles.priceunit} onchange={calcTiles}>
                            <option value='un'>Por Unidade</option>
                            <option value='ar'>Por Área</option>
                            <option value='pc'>Por Pacote</option>
                    </select>
                    {#if tiles.priceunit === 'pc'}
                        <input type="number" bind:value={tiles.packsize} placeholder="Itens / pacote" step="1" min="2" oninput={calcTiles} />
                    {/if}
                </div>
                <div>
                    <div>Entre a margem (%)</div>
                    <input type="number" bind:value={tiles.margin} placeholder="N %" step="0.01" min="0" oninput={calcTiles} />
                </div>                

                <div>
                    <h3>Resultado</h3>
                    <div>
                        <div>
                            Peças: {tiles.result}
                        </div>
                        <div>Valor: R$ {tiles.resultcost}</div>
                        <div>Valor por {getUnit(tiles.areaunit).toLowerCase()}: R$ {tiles.priceperarea}</div>
                        <div>Área: {tiles.area} {getUnit(tiles.areaunit).toLowerCase()}</div>
                    </div>
                </div>
            </div>
        {:else if mode === 1}
            <div class="area">
                <h5>Calcule a área total de diversas superfícies diferentes podendo usar unidades de medida diferentes</h5>
                <table>
                    <thead>
                        <tr>
                            <td style="width: 120px">Comprimento</td>
                            <td style="width: 400px">Dimensões</td>
                            <td>Unidade</td>
                            <td style="width: 60px"></td>
                        </tr>
                    </thead>
                    <tbody>
                        {#each areas as area, ind}
                            {@const isLast = ind === areas.length - 1}
                            <tr>
                                <td>
                                    <select bind:value={area.shape}>
                                        {#each shapes as shape}
                                            <option value={shape.val}>{shape.lbl}</option>
                                        {/each}
                                    </select>
                                </td>
                                <td>
                                    {#if area.shape === 'rect'}
                                        <input type="number" bind:value={area.dim1} placeholder="Largura" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim2} placeholder="Comprimento" step="0.01" min="0" />      
                                    {:else if area.shape === 'circ'}
                                        <input type="number" bind:value={area.dim1} placeholder="Raio Horizontal" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim2} placeholder="Raio Vertical" step="0.01" min="0" />      
                                    {:else if area.shape === 'arc'}
                                        <input type="number" bind:value={area.dim1} placeholder="Raio" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim2} placeholder="Ângulo (Graus)" step="0.01" min="0" />                                              
                                    {:else if area.shape === 'tria'}
                                        <input type="number" bind:value={area.dim1} placeholder="Lado 1" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim2} placeholder="Lado 2" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim3} placeholder="Lado 3" step="0.01" min="0" />
                                    {:else if area.shape === 'trap'}
                                        <input type="number" bind:value={area.dim1} placeholder="Base 1" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim2} placeholder="Base 2" step="0.01" min="0" />
                                        <input type="number" bind:value={area.dim3} placeholder="Altura" step="0.01" min="0" />                                        
                                    {:else if area.shape === 'hexa'}
                                        <input type="number" bind:value={area.dim1} placeholder="Lado" step="0.01" min="0" />                                      
                                    {/if}
                                </td>
                                <td>
                                    <select bind:value={area.unit}>
                                        {#each straightUnits as un}
                                            <option value={un.val}>{un.lbl}</option>
                                        {/each}
                                    </select> 
                                </td>
                                <td class="cmds">
                                    <div>
                                        {#if isLast}
                                            <a href onclick={newArea} title="Add"><i class="ph ph-plus-circle"></i></a>
                                        {/if}
                                        <a href onclick={delArea.bind(this, ind)} title="Del"><i class="ph ph-trash"></i></a>                                        
                                    </div>

                                    
                                </td>
                            </tr>
                        {/each}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4">
                                Total: {convert('cm2-' + mainUnit.val ,totalAreaCm2).toFixed(4) + ' ' + mainUnit.lbl}
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        {/if}
    </main>
</section>


<style>

    section {
        display: flex;
        flex-direction: column;
        height: 100dvh;
    }
    
    nav {
        background-color:  var(--border);
        align-items: center;
        display: flex;
        justify-content: space-between;
        padding: 10px;
        font-size: 18px;
        font-weight: bold;
    }

    main {
        display: flex;
        flex-direction: column;
        height: 100%;        
        flex-grow: 1;
        padding: 10px;
    }

    .tiles {
        display: flex;
        flex-direction: column;
        gap: 1em;
        flex-grow: 1;
        overflow-y: auto;
        height: stretch;
    }

    .tabs {
        margin: 0 0 1em;
    }

    .area {
        margin: 0 auto;
    }

    .area table {
        table-layout: fixed;
    }

    .area td {
        text-align: left;
    }

    .area td.cmds > div {
        display: flex;
        gap: 8px;  
        justify-content: end;
    }

    .area td.cmds > div > a {
        font-size: larger;
        text-decoration: none;
        color: inherit;
        display: flex;
        align-items: center;
    }
</style>