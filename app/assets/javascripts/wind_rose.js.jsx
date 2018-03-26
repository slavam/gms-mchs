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
    this.yearChange = this.yearChange.bind(this);
    this.cityChange = this.cityChange.bind(this);
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
        <input type="number" min="2015" max="2099" step="1" value={this.state.year} onChange={this.yearChange}/>
        <SelectCity cities={this.props.cities} onCityChange={this.cityChange} />
        <input type="submit" value="Пересчитать" />
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
      cityName: this.props.cityName
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(year, cityId){
    this.state.year = year;
    this.state.cityId = cityId;
    let that = this;
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "/measurements/wind_rose?year="+year+"&city_id="+cityId
      }).done((data) => {
        that.setState({matrix: data.matrix, year: data.year, cityName: data.cityName});
      }).fail((res) => {
        that.setState({errors: ["Проблемы с чтением данных из БД"]});
      }); 
  }

  render(){
    // let desiredLink = "/synoptic_observations/get_meteoparams.pdf?year="+this.state.year+"&month="+this.state.month+"&station_id="+this.state.stationId;
    // let table = this.state.meteoParams.length > 0 ?
    //   <div>
    //     <p>Год: {this.state.year}. Месяц: {this.state.month}. Метеостанция: {this.state.stationName}</p>
    //     <MeteoParamsTable meteoParams={this.state.meteoParams} />
    //     <p>Число замеров: {this.state.meteoParams.length}</p>
    //     <a href={desiredLink}>Распечатать</a>
    //   </div> : '';
    return(
      <div>
        <h1>Повторяемость штилей и направлений ветра по городу {this.state.cityName} по данным наблюдений репрезентативной метеорологической станции за {this.state.year} год</h1>
        <WindRoseTable matrix={this.state.matrix} />
        <h3>Задайте год и город</h3>
        <WindRoseForm year={this.state.year} cities={this.props.cities} onFormSubmit={this.handleFormSubmit}/>
      </div>
    );
  }
}
