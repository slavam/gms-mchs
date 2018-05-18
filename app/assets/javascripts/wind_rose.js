// import {Radar} from 'react-chartjs-2';
const Radar = require('react-chartjs-2').Radar;

const WindRoseTable = ({matrix}) => {
  let mns = ["Год","Январь",'','','','','', "Июль"];
  let table = [];
  var rows = [];
  var i;
  for (let j of [0,1,7]){
    rows = [];
    rows.push(<td key="9">{mns[j]}</td>);
    for (i = 0; i < 9; i++) { 
      let index = '['+j+', '+i+']';
      rows.push(<td key={i}>{isNaN(matrix[index]) ? '' : Math.round(matrix[index]) }</td>);
    }
    table.push(<tr key={j}>{rows}</tr>);
  }
  return (
    <table className="table table-hover">
      <thead>
        <tr>
          <th>Период</th>
          <th>С</th>
          <th>СВ</th>
          <th>В</th>
          <th>ЮВ</th>
          <th>Ю</th>
          <th>ЮЗ</th>
          <th>З</th>
          <th>СЗ</th>
          <th>Штиль</th>
        </tr>
      </thead>
      <tbody>{table}</tbody>
    </table>
  );
};

class WindRoseForm extends React.Component{
  constructor(props){
    super(props);
    this.state={
      year: this.props.year,
      cityId: 1
    };
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  yearChange(e){
    this.setState({year: e.target.value});
  }
  cityChange(value){
    this.setState({cityId: +value});
  }
  handleSubmit(e) {
    e.preventDefault();
    this.props.onFormSubmit(this.state.year, this.state.cityId);
  }
  render(){
    return(
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <input type="number" min="2015" max="2099" step="1" value={this.state.year} onChange={(event) => this.yearChange(event)}/>
        <SelectCity cities={this.props.cities} onCityChange={(event) => this.cityChange(event)}/>
        <input type="submit" value="Пересчитать"/>
      </form>
    );
  }
}

class WindRose extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      matrix: this.props.matrix,
      year: this.props.year,
      cityName: this.props.cityName,
      cityId: this.props.cityId,
      maxJul: this.props.maxJul
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    // this.printHandle = this.printHandle.bind(this);
  }
  handleFormSubmit(year, cityId){
    this.state.year = year;
    this.state.cityId = cityId;
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "/measurements/wind_rose?year="+year+"&city_id="+cityId
      }).done((data) => {
        this.setState({matrix: data.matrix, year: data.year, cityName: data.cityName, maxValue: data.maxValue});
      }).fail((res) => {
        this.setState({errors: ["Проблемы с чтением данных из БД"]});
      }); 
  }
  printHandle(e){
    let canvases = document.querySelectorAll('canvas');
    let bigCanvas = document.createElement('canvas');
    bigCanvas.id = "CursorLayer";
    bigCanvas.width = canvases[0].width*3;
    bigCanvas.height = canvases[0].height;
    bigCanvas.style.zIndex = 8;
    let body = document.getElementsByTagName("body")[0];
    body.appendChild(bigCanvas);
    let destCtx = bigCanvas.getContext('2d');
    let i = 0;
    [].forEach.call(canvases, (canvas) => {
      destCtx.drawImage(canvas, canvas.width*i, 0);
      i += 1;
    });
	  let canvasImg = bigCanvas.toDataURL("image/png");
	  $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {canvas_image: canvasImg}, 
      url: "/measurements/print_wind_rose" 
      }).done((data) => {
        alert("График сохранен. Все готово для печати");
      }).fail((res) => {
        alert("Проблемы с сохранением графика");
      }); 
      
  }

  render(){
    let january_data = [];
    let july_data = [];
    let year_data = [];
    let i;
    let index = '';
    for (i = 0; i < 8; i++) { 
      index = '[0, '+i+']';
      year_data.push(Math.round(this.state.matrix[index]));
    }
    for (i = 0; i < 8; i++) { 
      index = '[1, '+i+']';
      january_data.push(Math.round(this.state.matrix[index]));
    }
    for (i = 0; i < 8; i++) { 
      index = '[7, '+i+']';
      july_data.push(Math.round(this.state.matrix[index]));
    }
    const dataYear = {
      labels: ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'],
      datasets: [
        {
          label: 'Год',
          backgroundColor: 'rgba(179,181,198,0.2)',
          borderColor: 'rgba(179,181,198,1)',
          pointBackgroundColor: 'rgba(179,181,198,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(179,181,198,1)',
          data: year_data
        }
      ]
    };
    const dataJan = {
      labels: ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'],
      datasets: [
        {
          label: 'Январь',
          backgroundColor: 'rgba(55,99,232,0.2)',
          borderColor: 'rgba(55,99,232,1)',
          pointBackgroundColor: 'rgba(55,99,232,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(255,99,132,1)',
          data: january_data 
        },
      ]
    };
    const dataJul = {
      labels: ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'],
      datasets: [
        {
          label: 'Июль',
          backgroundColor: 'rgba(255,199,32,0.2)',
          borderColor: 'rgba(255,199,32,1)',
          pointBackgroundColor: 'rgba(255,199,32,1)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgba(255,99,132,1)',
          data: july_data
        }
      ]
    };
    let desiredLink = "/measurements/wind_rose.pdf?year="+this.state.year+"&city_id="+this.state.cityId; 
    let options = {maintainAspectRatio: false, 
              scale: {
                  ticks : {
                    suggestedMin: 0,
                    // suggestedMax: 100
                  }
              }};
    let radar = 
    <div>
      <table className="table table-hover">
        <thead>
          <tr>
            <th width="33%"></th>
            <th width="33%"></th>
            <th width="33%"></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><Radar data={dataYear} height={280} options={options}/></td>
            <td><Radar data={dataJan} height={280} options={options}/></td> 
            <td>{this.state.maxJul > 0 ? <Radar data={dataJul} height={280} options={options}/> : ''}</td>
          </tr>
        </tbody>
      </table>
      
      <button type="button" id="download-pdf" onClick={(event) => this.printHandle(event)}>Сохранить график</button><br/>
      <a href={desiredLink}>Печать. Сначала сохраните график, пожалуйста</a>
    </div>;
    return(
      <div>
        <h1>Повторяемость штилей и направлений ветра по городу {this.state.cityName} по данным наблюдений репрезентативной метеорологической станции за {this.state.year} год</h1>
        <WindRoseTable matrix={this.state.matrix} />
        <h3>Задайте год и город</h3>
        <WindRoseForm year={this.state.year} cities={this.props.cities} onFormSubmit={this.handleFormSubmit}/>
        {radar}
      </div>
    );
  }
}
export default WindRose;