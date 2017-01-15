class MonthYearForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      month: this.props.month,
      year: this.props.year
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleMonthChange = this.handleMonthChange.bind(this);
    this.handleYearChange = this.handleYearChange.bind(this);
  }
  handleMonthChange(e) {
    this.setState({month: e.target.value});
  }
  handleYearChange(e) {
    this.setState({year: e.target.value});
  }
  handleSubmit(e) {
    e.preventDefault();
    var month = this.state.month.trim();
    var year = this.state.year.trim();
    if (!year || !month) {
      return;
    }
    this.props.onParamsSubmit({month: month, year: year});
  }
  render() {
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <input
          type="text"
          placeholder="Месяц..."
          value={this.state.month}
          onChange={this.handleMonthChange}
        />
        <input
          type="text"
          placeholder="Год..."
          value={this.state.year}
          onChange={this.handleYearChange}
        />
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}

class Tcx1TempRow extends React.Component{
  render() {
    var stations = {34622: "Амвросиевка", 34524: "Дебальцево", 34519: "Донецк", 34615: "Волноваха", 34712: "Мариуполь", 34510: "Артемовск", 34514: "Красноармейск"};
    var v = [];
    var nd = nd = this.props.numDays;
    var style = {
      backgroundColor: '#ddd'
    };
    for(var i=0;i<=nd;i++){
      v.push(<td style={(i % 2 == 0) ? style : {}} key={i.toString()}>{this.props.vector[i]}</td>);
      
    };
    return (
      <tr>
        <td>{stations[this.props.station]}</td>
        {v}
      </tr>
    );
  }
}

class AvgTempsTable extends React.Component{
  render() {
    var rows = [];
    var temps, nd;
    var th = [];
    temps = this.props.avgTemps;
    nd = this.props.numDays;
    
    ['34519', '34524', '34622', '34514', '34615', '34510', '34712'].forEach(function(s) {
      for(var i=1;i<=nd;i++){
        th.push(temps[s+(i<10 ? '-0'+i.toString() : '-'+i.toString())]);
      }
      rows.push(<Tcx1TempRow station={s} vector={th} numDays={nd} key={s}/>);
      th = [];
    });
    for(var i=1;i<=this.props.numDays;i++){
      th.push(<th key={i.toString()}>{i}</th>);
    };
  
    return (
      <table>
        <thead>
          <tr>
            <th>Метеостанция</th>
            {th}
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}


class Tcx1Show extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      month: this.props.month,
      monthName: this.props.monthName,
      year: this.props.year,
      numDays: this.props.numDays,
      avgTemps: this.props.avgTemps,
      maxTemps: this.props.maxTemps,
      minTemps: this.props.minTemps,
      maxWindSpeed: this.props.maxWindSpeed,
      minSoilTemps: this.props.minSoilTemps,
      minHumidity: this.props.minHumidity,
      rainfall: this.props.rainfall
    };
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
  }

  handleParamsSubmit(params) {
    $.ajax({
      type: 'GET',
      url: "get_tcx1_data?month="+params.month+"&year="+params.year
      }).done(function(data) {
        this.setState({
          avgTemps: data.avgTemps,
          monthName: data.monthName,
          numDays: data.numDays,
          year: data.year,
          maxTemps: data.maxTemps,
          minTemps: data.minTemps,
          maxWindSpeed: data.maxWindSpeed,
          minSoilTemps: data.minSoilTemps,
          minHumidity: data.minHumidity,
          rainfall: data.rainfall
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  render(){
    return(
      <div>
        <h2> Таблица для обработки агрометеорологических наблюдений за {this.state.monthName} {this.state.year} года</h2>
        <MonthYearForm onParamsSubmit={this.handleParamsSubmit} year={this.props.year} month={this.props.month}/>
        <h3> Средняя температура воздуха, °С </h3>
        <AvgTempsTable avgTemps={this.state.avgTemps} numDays={this.state.numDays} />
        <h3> Максимальная температура воздуха, °С </h3>
        <AvgTempsTable avgTemps={this.state.maxTemps} numDays={this.state.numDays} />
        <h3> Минимальная температура воздуха, °С </h3>
        <AvgTempsTable avgTemps={this.state.minTemps} numDays={this.state.numDays} />
        <h3> Максимальная скорость ветра, м/с </h3>
        <AvgTempsTable avgTemps={this.state.maxWindSpeed} numDays={this.state.numDays} />
        <h3> Количество осадков, мм </h3>
        <AvgTempsTable avgTemps={this.state.rainfall} numDays={this.state.numDays} />
        <h3> Минимальная температура почвы, °С </h3>
        <AvgTempsTable avgTemps={this.state.minSoilTemps} numDays={this.state.numDays} />
        <h3> Минимальная относительная влажность воздуха, % </h3>
        <AvgTempsTable avgTemps={this.state.minHumidity} numDays={this.state.numDays} />
      </div>
    );
  }
}