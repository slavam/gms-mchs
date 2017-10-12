class DateForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      calcDate:  this.props.calcDate 
    };
    this.dateChange = this.dateChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    var calcDate = this.state.calcDate.trim();
    if (!calcDate) { 
      return;
    }
    this.props.onDateSubmit(calcDate);
  }
  dateChange(e){
    this.setState({calcDate: e.target.value});
  }
  render() {
    return (
    <div className="col-md-12">
      <form className="dateForm" onSubmit={this.handleSubmit}>
        <input type="date" name="input-date" value={this.state.calcDate} onChange={this.dateChange} required="true" autoComplete="on" />
        <input type="submit" value="Пересчитать" />
      </form>
    </div>
    );
  }
}

class TemperaturesTable extends React.Component{
  render() {
    var rows = [];
    var tds = [];
    var temps;
    var stations = ["", "Донецк", "Амвросиевка", "Дебальцево", "Волноваха", "Мариуполь"];
    var stationId;
    var avg;
    var n;
    var i;
    
    temps = this.props.temperatures;
    
    ['3', '1', '2', '4', '5'].forEach(function(s) {
      stationId = s;
      tds = [];
      n = 0;
      avg = 0.0;
      ['9', '12', '15', '18', '21', '0', '3', '6'].forEach(function(t) {
        i = "["+stationId+", "+t+"]";
        if(temps[i] != null){
          n++;
          avg += +(temps[i]);
        }
        tds.push(<td key={t}>{temps[i]}</td>);
        // <td>{temps["["+s+", 9]"]}</td><td>{temps["["+s+", 12]"]}</td><td>{temps["["+s+", 15]"]}</td><td>{temps["["+s+", 18]"]}</td><td>{temps["["+s+", 21"]}</td><td>{temps["["+s+", 0]"]}</td><td>{temps["["+s+", 3]"]}</td><td>{temps["["+s+", 6]"]}</td>
      });
      rows.push(<tr key={s}><td>{stations[+s]}</td>{tds}<td><b>{n > 0 ? (avg/n).toFixed(2) : ''}</b></td></tr>);
    });
  
    return (
      <table className = "table table-hover">
        <thead>
          <tr>
            <th>Метеостанция</th>
            <th>09</th>
            <th>12</th>
            <th>15</th>
            <th>18</th>
            <th>21</th>
            <th>00</th>
            <th>03</th>
            <th>06</th>
            <th>Средняя</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class HeatDonbass extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      calcDate: this.props.calcDate,
      temperatures: this.props.temperatures
    };
    this.handleDateSubmit = this.handleDateSubmit.bind(this);
  }

  handleDateSubmit(calcDate) {
    $.ajax({
      type: 'GET',
      url: "get_temps?calc_date="+calcDate
      }).done(function(data) {
        this.setState({
          calcDate: data.calcDate,
          temperatures: data.temperatures
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }

  render(){
    return(
      <div className="col-md-6 col-md-offset-3">
        <h4>К договору №08/16-17/03   ГП "Донбасстеплоэнерго"   тел. 304-74-24</h4>
        <DateForm calcDate={this.props.calcDate} onDateSubmit={this.handleDateSubmit} />
        <h3>Температура воздуха (°С) в сроки наблюдений по данным метеорологических станций {this.state.calcDate}</h3>
        <TemperaturesTable temperatures={this.state.temperatures} />
      </div>
    );
  }
}
