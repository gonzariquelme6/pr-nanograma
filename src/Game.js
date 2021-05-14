import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import Mode from './Mode';

class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      grid: null,
      rowClues: null,
      colClues: null,
      waiting: false,
      won:false,
      current_mode: '#',
      filasCorrectas:[],
      colsCorrectas:[],
      statusText:"Partida en curso.",
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = 'init(PistasFilas, PistasColumns, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
        });
      this.checkInicio();
      }
    });
  }

  checkInicio(){
    console.log("CHECK INICIO");
    const pistasf = JSON.stringify(this.state.rowClues);
    const pistasc = JSON.stringify(this.state.colClues);
    const grilla = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); 

    console.log(pistasf);
    console.log(pistasc);
    console.log(grilla);
    const queryS = `checkInit("${pistasf}", ${pistasc}, ${grilla}, FilasSat, ColsSat)`;
    this.pengine.query(queryS,(success, response) =>{
      if (success){
        this.setState({
          filasCorrectas: response['FilasSat'],
          colsCorrectas: response['ColsSat']
        })
        console.log(this.state.filasCorrectas);
      }else{
        console.log("FAILLL");
      }  
    });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting || this.state.won) {
      return;
    }

    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const filas = JSON.stringify(this.state.rowClues);
    const columnas = JSON.stringify(this.state.colClues);
    
    // Build Prolog query to make the move, which will look as follows:
    // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    const queryS = `put("${this.state.current_mode}", [${i}, ${j}], ${filas}, ${columnas}, ${squaresS}, GrillaRes, FilaSat, ColSat)`;
    this.setState({
      waiting: true
    });
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        let auxFilas = this.state.filasCorrectas;
        auxFilas[i] = response['FilaSat'];
        let auxCols = this.state.colsCorrectas;
        auxCols[j] = response['ColSat'];
        this.setState({
          grid: response['GrillaRes'],
          filaCorrecta: response['FilaSat'],
          colCorrecta: response['ColSat'],
          waiting: false,
          filasCorrectas:auxFilas,
          colsCorrectas:auxCols
        });

        let todasFilas = this.state.filasCorrectas.every(elem=> elem===1);
        let todasCols = this.state.colsCorrectas.every(elem=> elem===1);

        if(todasFilas&&todasCols){
          this.setState({
            statusText: "Ganaste!",
            won:true
          })
        }
      } else {
        console.log("fail");
        this.setState({
          waiting: false
        });
      }
    });
  }
  modeClick(){
    if(this.state.current_mode==='#'){
      this.setState({current_mode:'X'});
    }else{
      this.setState({current_mode:'#'});
    }
  }
  render() {
    if (this.state.grid === null) {
      return null;
    }
    return (
      <div className="game">
        <div className="pistasCol"></div>
        <Board
          grid={this.state.grid}
          rowClues={this.state.rowClues}
          colClues={this.state.colClues}
          onClick={(i, j) => this.handleClick(i,j)}
          RowSat = {this.state.filasCorrectas}
          ColSat = {this.state.colsCorrectas}
        />

        <div>
          Modo actual: <Mode value={this.state.current_mode} onClick={() => this.modeClick()} />
        </div>

        <div className="gameInfo">
          {this.state.statusText}
        </div>
      </div>
    );
  }
}

export default Game;
